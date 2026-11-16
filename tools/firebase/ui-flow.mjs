import { chromium, expect } from '@playwright/test';
import { mkdir, writeFile, readFile } from 'node:fs/promises';

const baseUrl = process.env.APP_URL || 'http://127.0.0.1:5173';
const email = 'ana.demo.' + Date.now().toString(36).slice(-5) + '@exemplo.com';
const senha = 'FocoP2!2026';
const screenshots = 'docs/capturas';
await mkdir(screenshots, { recursive: true });
await mkdir('docs/video', { recursive: true });
const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({
  viewport: { width: 390, height: 844 }, deviceScaleFactor: 1,
  recordVideo: { dir: 'tmp/videos', size: { width: 390, height: 844 } },
});
const page = await context.newPage();
const errors = [];
let sucesso = false;
page.on('pageerror', (error) => errors.push(error.message));
const pause = () => page.waitForTimeout(450);
async function capture(nome) {
  await pause();
  if (['03-inicio','05-tarefas','06-detalhes','07-concluida','09-configuracoes-escuro','10-inicio-escuro'].includes(nome)) {
    await page.waitForTimeout(4100);
  }
  await page.screenshot({ path: screenshots + '/' + nome + '.png' });
}
async function habilitar(page) {
  await page.goto(baseUrl, { waitUntil: 'networkidle' });
  await page.locator('flt-semantics-placeholder').evaluate((node) => node.click()).catch(() => {});
}
async function menu(destino, aba = page) {
  await aba.getByRole('button', { name: 'Abrir menu de navegação' }).click();
  await aba.getByText(destino, { exact: true }).click();
  await pause();
}
function cartao(titulo) {
  return page.getByRole('group', { name: new RegExp('^' + titulo + '\\s') });
}
async function entrar(emailAtual = email, senhaAtual = senha) {
  await preencher('E-mail', emailAtual);
  await preencher('Senha', senhaAtual);
  await page.getByRole('button', { name: 'Entrar', exact: true }).click();
}
async function preencher(nome, valor) {
  const campo = page.getByRole('textbox', { name: new RegExp('^' + nome + '(?:\\s|$)') });
  await campo.click();
  await page.waitForTimeout(200);
  await campo.press('ControlOrMeta+A');
  await campo.press('Backspace');
  await page.waitForTimeout(150);
  await campo.pressSequentially(valor, { delay: 15 });
  await campo.press('Tab');
  await page.waitForTimeout(200);
}
try {
  await habilitar(page);
  await capture('01-login');
  await page.getByRole('button', { name: 'Criar conta', exact: true }).click();
  await preencher('Nome', 'Ana Maria');
  await preencher('E-mail', email);
  await preencher('Senha', senha);
  await preencher('Confirmar senha', senha);
  await capture('02-cadastro');
  await page.getByRole('button', { name: 'Criar minha conta' }).click();
  await expect(page.getByText('Olá, Ana.', { exact: true })).toBeVisible({ timeout: 20000 });
  for (const [titulo, descricao, prioridade] of [
    ['Estudar Flutter', 'Revisar navegação, Models e integração com Firebase.', 'Alta'],
    ['Organizar a semana', 'Separar os horários para estudo e preparar a apresentação.', 'Média'],
  ]) {
    await page.getByRole('button', { name: 'Nova tarefa' }).click();
    await preencher('Título', titulo);
    await preencher('Descrição', descricao);
    await page.getByRole('checkbox', { name: prioridade, exact: true }).click();
    await capture('04-formulario');
    await page.getByRole('button', { name: 'Criar tarefa', exact: true }).click();
    await expect(page.getByText('Olá, Ana.', { exact: true })).toBeVisible();
  }
  await capture('03-inicio');
  await menu('Minhas tarefas');
  await expect(cartao('Estudar Flutter')).toBeVisible();
  await expect(cartao('Organizar a semana')).toBeVisible();
  await capture('05-tarefas');
  const outraAba = await context.newPage();
  await habilitar(outraAba);
  await menu('Minhas tarefas', outraAba);
  await expect(outraAba.getByRole('group', { name: /^Estudar Flutter\s/ })).toBeVisible();
  await cartao('Estudar Flutter').click();
  await capture('06-detalhes');
  await page.getByRole('button', { name: 'Editar tarefa', exact: true }).click();
  await preencher('Título', 'Revisar Flutter e Firebase');
  await page.getByRole('button', { name: 'Salvar alterações', exact: true }).click();
  await expect(page.getByRole('button', { name: 'Marcar como concluída', exact: true })).toBeVisible();
  await expect(outraAba.getByRole('group', { name: /^Revisar Flutter e Firebase\s/ })).toBeVisible();
  await page.getByRole('button', { name: 'Marcar como concluída', exact: true }).click();
  await expect(page.getByRole('button', { name: 'Marcar como pendente', exact: true })).toBeVisible();
  await capture('07-concluida');
  await page.getByRole('button', { name: 'Voltar', exact: true }).click();
  await cartao('Organizar a semana').click();
  await page.getByRole('button', { name: 'Excluir tarefa', exact: true }).click();
  await capture('08-exclusao');
  await page.getByRole('button', { name: 'Excluir', exact: true }).click();
  await expect(cartao('Organizar a semana')).toHaveCount(0);
  await expect(outraAba.getByRole('group', { name: /^Organizar a semana\s/ })).toHaveCount(0);
  await outraAba.close();
  await menu('Configurações');
  await page.getByRole('switch', { name: /Tema escuro/ }).click();
  await capture('09-configuracoes-escuro');
  await page.reload({ waitUntil: 'networkidle' });
  await page.locator('flt-semantics-placeholder').evaluate((node) => node.click()).catch(() => {});
  await expect(page.getByText('Olá, Ana.', { exact: true })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Usar tema claro' })).toBeVisible();
  await capture('10-inicio-escuro');
  await menu('Sobre o aplicativo');
  await capture('11-sobre');
  await menu('Sair');
  await page.getByRole('button', { name: 'Sair', exact: true }).click();
  await expect(page.getByRole('textbox', { name: 'E-mail', exact: true })).toBeVisible();
  await entrar(email, 'senha-incorreta');
  await expect(page.getByText('E-mail ou senha incorretos. Confira e tente novamente.', { exact: true }).first()).toBeVisible();
  await capture('12-erro-autenticacao');
  await entrar();
  await expect(page.getByText('Olá, Ana.', { exact: true })).toBeVisible();
  await menu('Minhas tarefas');
  await expect(cartao('Revisar Flutter e Firebase')).toBeVisible();
  const nuvem = Boolean(process.env.UI_FIREBASE_CONFIG);
  const config = nuvem ? JSON.parse(await readFile(process.env.UI_FIREBASE_CONFIG, 'utf8')) : null;
  const authUrl = nuvem
    ? 'https://identitytoolkit.googleapis.com/v1/'
    : 'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/';
  const apiKey = config?.FIREBASE_API_KEY || 'demo-api-key-meu-foco';
  const login = await fetch(authUrl + 'accounts:signInWithPassword?key=' + apiKey, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password: senha, returnSecureToken: true }),
  }).then((response) => response.json());
  if (!login.idToken) throw new Error('Não foi possível verificar os dados do Firebase.');
  const dataUrl = new URL(nuvem ? config.FIREBASE_DATABASE_URL : 'http://127.0.0.1:9000');
  dataUrl.pathname = '/usuarios/' + login.localId + '/tarefas.json';
  if (!nuvem) dataUrl.searchParams.set('ns', 'demo-meu-foco-default-rtdb');
  dataUrl.searchParams.set('auth', login.idToken);
  const tarefas = await fetch(dataUrl).then((response) => response.json());
  expect(Object.keys(tarefas)).toHaveLength(1);
  expect(Object.values(tarefas)[0].titulo).toBe('Revisar Flutter e Firebase');
  expect(Object.values(tarefas)[0].concluida).toBe(true);
  const outraConta = await fetch(authUrl + 'accounts:signUp?key=' + apiKey, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'outra.' + email, password: senha, returnSecureToken: true }),
  }).then((response) => response.json());
  if (!outraConta.idToken) throw new Error('Falha ao criar segunda conta de teste.');
  dataUrl.searchParams.set('auth', outraConta.idToken);
  const acessoAlheio = await fetch(dataUrl);
  expect(acessoAlheio.status).toBe(401);
  const evidencia = {
    ambiente: nuvem ? 'Firebase na nuvem' : 'Emuladores oficiais do Firebase',
    banco: nuvem ? config.FIREBASE_DATABASE_URL : 'demo-meu-foco-default-rtdb',
    usuarioDeTeste: email,
    uid: login.localId,
    tarefas,
    isolamentoEntreUsuarios: 'Acesso de outra conta negado pelo servidor (HTTP 401).',
    listenerEmTempoReal: 'Edição e exclusão recebidas por uma segunda aba aberta.',
    sessaoPersistente: true,
    temaPersistente: true,
    errosJavaScript: errors,
  };
  await writeFile('docs/evidencias-firebase.json', JSON.stringify(evidencia, null, 2) + '\n');
  const escapar = (value) => value.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
  await page.setContent('<html lang="pt-BR"><meta charset="UTF-8"><body style="margin:0;background:#f6f5f0;color:#17221b;font:15px system-ui;padding:28px">' +
    '<p style="color:#29644c;font-weight:700">MEU FOCO · VERIFICAÇÃO</p><h1 style="font-size:28px">Dados reais no Firebase</h1>' +
    '<p>' + evidencia.ambiente + '</p><p>Leitura autenticada do Realtime Database após editar, concluir e excluir tarefas.</p>' +
    '<pre style="white-space:pre-wrap;overflow-wrap:anywhere;font:12px monospace;background:#fffefa;border:1px solid #d5dfd5;padding:16px;border-radius:16px">' +
    escapar(JSON.stringify(tarefas, null, 2)) + '</pre><p style="color:#29644c">✓ Outra conta: acesso negado pelo servidor.<br>✓ Atualização ao vivo em duas abas.<br>✓ Tema e sessão preservados.</p></body></html>');
  await capture('13-firebase-dados');
  await page.waitForTimeout(5000);
  expect(errors).toEqual([]);
  sucesso = true;
  console.log('FLUXO COMPLETO OK: cadastro, duas tarefas, consulta, edição, conclusão, exclusão, tema, reabertura, logout e login.');
} catch (error) {
  await page.screenshot({ path: 'tmp/ui-erro.png' });
  await writeFile('tmp/ui-erro.txt', await page.locator('body').ariaSnapshot());
  console.error(error.message);
  console.error(await page.locator('body').ariaSnapshot());
  process.exitCode = 1;
} finally {
  await context.close();
  if (sucesso) await page.video().saveAs('docs/video/demonstracao.webm');
  await browser.close();
}
