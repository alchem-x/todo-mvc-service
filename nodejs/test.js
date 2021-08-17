import http from 'http'
import assert from 'assert/strict'
import fetch from 'node-fetch'

import service from './service.js'
import { prune } from './store.js'

async function addTodo(content) {
    const response = await fetch('http://localhost:8080/todo', {
        headers: {
            'Content-Type': 'application/json'
        },
        method: 'POST',
        body: JSON.stringify({ content }),
    })
    return await response.json()
}

async function updateTodo(todo) {
    await fetch('http://localhost:8080/todo', {
        headers: {
            'Content-Type': 'application/json'
        },
        method: 'PUT',
        body: JSON.stringify(todo),
    })
}

async function getTodoList(status = '') {
    const qs = new URLSearchParams({ status }).toString()
    const response = await fetch('http://localhost:8080/todo/list?' + qs)
    return await response.json()
}

async function deleteTodo(idList) {
    const qs = new URLSearchParams(idList.map(id => ['id', id])).toString()
    await fetch('http://localhost:8080/todo?' + qs, { method: 'DELETE' })
}

async function test() {
    assert.strictEqual(0, (await getTodoList()).length)

    await addTodo('Todo')
    const todoList = await getTodoList()
    assert.strictEqual(1, todoList.length)

    const todo = todoList[0]
    assert.strictEqual('Todo', todo.content)
    assert.strictEqual('active', todo.status)

    await addTodo('Another Todo');
    await updateTodo({ ...todo, status: 'completed' })
    assert.strictEqual(1, (await getTodoList('completed')).length)
    assert.strictEqual(1, (await getTodoList('active')).length)

    const idList = (await getTodoList()).map(it => it.id)
    await deleteTodo(idList);
    assert.strictEqual(0, (await getTodoList()).length)
}

function runTestWithServer(test) {
    const app = http.createServer(service)
    app.listen(8080, async () => {
        try {
            await prune()
            await test()
            console.log('Tests passed')
        } finally {
            await prune()
        }
        app.close()
    })
}

runTestWithServer(test)


