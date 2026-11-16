import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
const auth = require('firebase-tools/lib/auth');
const { requireAuth } = require('firebase-tools/lib/requireAuth');
const { Client } = require('firebase-tools/lib/apiv2');
const project = process.argv[2] || 'gerenciamento-de-tarefas-2f419';
const account = auth.getGlobalDefaultAccount();
const options = { project, nonInteractive: true };
auth.setActiveAccount(options, account);
await requireAuth(options);
const cloud = new Client({ urlPrefix: 'https://cloudresourcemanager.googleapis.com', apiVersion: 'v1' });
const response = await cloud.post('projects/' + project + ':testIamPermissions', {
  permissions: ['firebase.projects.update', 'resourcemanager.projects.get',
    'serviceusage.services.enable', 'serviceusage.services.get', 'serviceusage.services.use'],
});
console.log(JSON.stringify({ conta: account.user.email, permissoes: response.body.permissions }));
