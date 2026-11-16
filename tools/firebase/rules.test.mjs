import { after, before, beforeEach, test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { ref, set, get, update, remove, onValue } from 'firebase/database';

let env;
const dados = (id = 't1') => ({
  id, titulo: 'Estudar Flutter', descricao: 'Revisar o conteúdo.',
  dataVencimento: '2026-11-20', prioridade: 'alta', concluida: false,
});
before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-meu-foco',
    database: {
      host: '127.0.0.1', port: 9000,
      rules: await readFile(new URL('../../database.rules.json', import.meta.url), 'utf8'),
    },
  });
});
beforeEach(() => env.clearDatabase());
after(() => env?.cleanup());

test('acesso anônimo é negado, inclusive no caminho de um usuário', async () => {
  const db = env.unauthenticatedContext().database();
  await assertFails(get(ref(db, 'usuarios/ana/tarefas')));
  await assertFails(set(ref(db, 'usuarios/ana/tarefas/t1'), dados()));
});
test('o proprietário cria, lê, edita, conclui e exclui sua tarefa', async () => {
  const db = env.authenticatedContext('ana').database();
  const tarefa = ref(db, 'usuarios/ana/tarefas/t1');
  await assertSucceeds(set(tarefa, dados()));
  assert.equal((await get(tarefa)).val().titulo, 'Estudar Flutter');
  await assertSucceeds(update(tarefa, { titulo: 'Revisar Flutter', concluida: true }));
  assert.equal((await get(tarefa)).val().concluida, true);
  await assertSucceeds(remove(tarefa));
  assert.equal((await get(tarefa)).exists(), false);
});
test('outra conta não pode consultar, alterar ou excluir a tarefa do proprietário', async () => {
  const ana = env.authenticatedContext('ana').database();
  const bob = env.authenticatedContext('bob').database();
  await set(ref(ana, 'usuarios/ana/tarefas/t1'), dados());
  const alheia = ref(bob, 'usuarios/ana/tarefas/t1');
  await assertFails(get(alheia));
  await assertFails(set(alheia, dados()));
  await assertFails(update(alheia, { concluida: true }));
  await assertFails(remove(alheia));
  await assertSucceeds(set(ref(bob, 'usuarios/bob/tarefas/t2'), dados('t2')));
  assert.equal(Object.keys((await get(ref(ana, 'usuarios/ana/tarefas'))).val()).length, 1);
});
test('leituras da raiz e da coleção geral continuam bloqueadas', async () => {
  const db = env.authenticatedContext('ana').database();
  await assertFails(get(ref(db)));
  await assertFails(get(ref(db, 'usuarios')));
  await assertFails(get(ref(db, 'usuarios/ana')));
});
test('registros inválidos, campos inesperados e IDs inconsistentes são rejeitados', async () => {
  const db = env.authenticatedContext('ana').database();
  const tarefa = ref(db, 'usuarios/ana/tarefas/t1');
  for (const invalido of [
    { ...dados(), titulo: '' },
    { ...dados(), titulo: 'a'.repeat(121) },
    { ...dados(), descricao: 'a'.repeat(2001) },
    { ...dados(), prioridade: 'urgente' },
    { ...dados(), concluida: 'sim' },
    { ...dados(), dataVencimento: '20/11/2026' },
    { ...dados(), id: 'id-alheio' },
    { ...dados(), campoExtra: true },
  ]) {
    await assertFails(set(tarefa, invalido));
  }
  const incompleto = dados();
  delete incompleto.descricao;
  await assertFails(set(tarefa, incompleto));
});
test('listener recebe as alterações em tempo real', async () => {
  const db = env.authenticatedContext('ana').database();
  const lista = ref(db, 'usuarios/ana/tarefas');
  let parar;
  const recebida = new Promise((resolve, reject) => {
    const timeout = setTimeout(() => reject(new Error('Listener não recebeu os dados.')), 5000);
    parar = onValue(lista, (snapshot) => {
      if (snapshot.child('t1/concluida').val() === true) {
        clearTimeout(timeout); resolve(snapshot.val());
      }
    }, reject);
  });
  await set(ref(db, 'usuarios/ana/tarefas/t1'), dados());
  await update(ref(db, 'usuarios/ana/tarefas/t1'), { concluida: true });
  assert.equal((await recebida).t1.concluida, true);
  parar();
});
