import { createRequire } from 'node:module';
import { mkdir, writeFile } from 'node:fs/promises';
import { spawnSync } from 'node:child_process';
import { resolve } from 'node:path';
const require = createRequire(import.meta.url);
const auth = require('firebase-tools/lib/auth');
const { requireAuth } = require('firebase-tools/lib/requireAuth');
const projects = require('firebase-tools/lib/management/projects');
const apps = require('firebase-tools/lib/management/apps');
const databases = require('firebase-tools/lib/management/database');
const apiEnabled = require('firebase-tools/lib/ensureApiEnabled');

const projectId = process.argv[2];
if (!projectId || !/^[a-z][a-z0-9-]{4,28}[a-z0-9]$/.test(projectId)) {
  throw new Error('Informe o ID do projeto Firebase como argumento.');
}
const account = auth.getProjectDefaultAccount(process.cwd()) || auth.getGlobalDefaultAccount();
if (!account) throw new Error('Entre primeiro com: firebase login --interactive');
const options = { project: projectId, nonInteractive: true };
auth.setActiveAccount(options, account);
await requireAuth(options);
try {
  let projeto;
  if (!(await projects.checkFirebaseEnabledForCloudProject(projectId))) {
    console.log('Ativando Firebase no projeto Google Cloud existente...');
    await projects.addFirebaseToCloudProject(projectId);
  }
  projeto = await projects.getFirebaseProject(projectId);
  console.log('Projeto Firebase disponível:', projeto.projectId);
  await apiEnabled.ensure(projectId, 'identitytoolkit.googleapis.com', 'auth', true);
  await apiEnabled.ensure(projectId, 'firebasedatabase.googleapis.com', 'database', true);

  const instancias = await databases.listDatabaseInstances(projectId, '-');
  let banco = instancias.find((item) => item.name === projectId + '-default-rtdb');
  if (!banco) {
    console.log('Criando o Realtime Database padrão...');
    banco = await databases.createInstance(
      projectId, projectId + '-default-rtdb', databases.DatabaseLocation.US_CENTRAL1,
      databases.DatabaseInstanceType.DEFAULT_DATABASE,
    );
  }
  console.log('Realtime Database pronto.');
  const existentes = await apps.listFirebaseApps(projectId, apps.AppPlatform.ANY);
  const android = existentes.find((a) => a.platform === 'ANDROID' &&
    (a.packageName || a.namespace) === 'br.com.meufoco.meu_foco')
    || await apps.createAndroidApp(projectId, { displayName: 'Meu Foco Android', packageName: 'br.com.meufoco.meu_foco' });
  const ios = existentes.find((a) => a.platform === 'IOS' &&
    (a.bundleId || a.namespace) === 'br.com.meufoco.meuFoco')
    || await apps.createIosApp(projectId, { displayName: 'Meu Foco iOS', bundleId: 'br.com.meufoco.meuFoco' });
  const web = existentes.find((a) => a.platform === 'WEB' && a.displayName === 'Meu Foco Web')
    || await apps.createWebApp(projectId, { displayName: 'Meu Foco Web' });
  console.log('Aplicativos Android, iOS e Web registrados.');


  const androidData = apps.getAppConfigFile(await apps.getAppConfig(android.appId, 'ANDROID'), 'ANDROID');
  const iosData = apps.getAppConfigFile(await apps.getAppConfig(ios.appId, 'IOS'), 'IOS');
  const webConfig = await apps.getAppConfig(web.appId, 'WEB');
  const androidConfig = JSON.parse(androidData.fileContents);
  const androidClient = androidConfig.client.find((c) =>
    c.client_info.android_client_info.package_name === 'br.com.meufoco.meu_foco');
  const xmlValue = (key) => {
    const match = iosData.fileContents.match(new RegExp('<key>' + key + '</key>\\s*<string>([^<]+)</string>'));
    return match?.[1];
  };
  const comum = {
    projectId, databaseURL: banco.databaseUrl,
    messagingSenderId: String(projeto.projectNumber),
  };
  const plataformas = {
    android: { ...comum, apiKey: androidClient.api_key[0].current_key, appId: android.appId },
    ios: { ...comum, apiKey: xmlValue('API_KEY'), appId: ios.appId, iosBundleId: 'br.com.meufoco.meuFoco' },
    web: { ...comum, apiKey: webConfig.apiKey, appId: web.appId, authDomain: webConfig.authDomain || projectId + '.firebaseapp.com' },
  };
  for (const [plataforma, config] of Object.entries(plataformas)) {
    if (!config.apiKey || !config.appId || !config.databaseURL) {
      throw new Error('Configuração incompleta para ' + plataforma);
    }
  }
  const dartOptions = Object.entries(plataformas).map(([plataforma, config]) =>
    '  static const ' + plataforma + ' = FirebaseOptions(\n' +
      Object.entries(config).map(([key, value]) => '    ' + key + ': ' + JSON.stringify(value) + ',').join('\n') +
    '\n  );').join('\n\n');
  const dart = "// Configurações públicas dos aplicativos registrados no Firebase.\n" +
    "import 'package:firebase_core/firebase_core.dart';\nimport 'package:flutter/foundation.dart';\n\n" +
    'abstract final class DefaultFirebaseOptions {\n  static const configurado = true;\n' +
    '  static FirebaseOptions get currentPlatform {\n' +
    '    if (kIsWeb) return web;\n' +
    '    return defaultTargetPlatform == TargetPlatform.iOS ? ios : android;\n  }\n\n' +
    dartOptions + '\n}\n';
  await mkdir('config', { recursive: true });
  await writeFile('lib/firebase_options.dart', dart);
  await writeFile('android/app/google-services.json', androidData.fileContents);
  await writeFile('ios/Runner/GoogleService-Info.plist', iosData.fileContents);
  for (const [plataforma, config] of Object.entries(plataformas)) {
    await writeFile('config/firebase.' + plataforma + '.json', JSON.stringify({
      USE_FIREBASE_EMULATOR: 'false',
      FIREBASE_API_KEY: config.apiKey, FIREBASE_APP_ID: config.appId,
      FIREBASE_PROJECT_ID: config.projectId, FIREBASE_DATABASE_URL: config.databaseURL,
      FIREBASE_MESSAGING_SENDER_ID: config.messagingSenderId,
      FIREBASE_AUTH_DOMAIN: config.authDomain || '',
    }, null, 2) + '\n');
  }
  await writeFile('.firebaserc', JSON.stringify({ projects: { default: projectId } }, null, 2) + '\n');
  const firebaseBin = require.resolve('firebase-tools/lib/bin/firebase');
  const deploy = spawnSync(process.execPath,
    [firebaseBin, 'deploy', '--only', 'auth,database', '--project', projectId, '--non-interactive'],
    { cwd: resolve('.'), stdio: 'inherit' });
  if (deploy.status !== 0) throw new Error('Falha ao configurar autenticacao e publicar regras do banco.');
  console.log('Firebase configurado. As opções públicas estão em lib/firebase_options.dart.');
} catch (error) {
  console.error('Configuração interrompida:', error.message);
  if (error.original?.message) console.error(error.original.message);
  process.exitCode = 1;
}
