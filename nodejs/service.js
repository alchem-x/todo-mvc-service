import { persistentToFile, readFromFile } from './store.js'

async function handleGetTodoList(status) {
    const todoList = await readFromFile()
    if (['active', 'completed'].includes(status)) {
        return todoList.filter(it => it.status === status)
    }
    return todoList
}

async function handleAddNewTodo(content) {
    if (!content) {
        throw new Error('Todo content must be not empty')
    }
    const todoList = await readFromFile()
    const newId = todoList.length ? Math.max(...todoList.map(it => it.id)) + 1 : 1
    const newTodo = {
        id: newId,
        content,
        status: 'active',
    }
    todoList.push(newTodo)
    await persistentToFile(todoList)
    return newTodo
}

async function handleUpdateTodo(todo) {
    if (!todo.id) {
        throw new Error('Todo ID is missing')
    }
    if (!['active', 'completed'].includes(todo.status)) {
        throw new Error('Illegal todo status')
    }
    if (!todo.content) {
        throw new Error('Todo content must be not empty')
    }
    const todoList = await readFromFile()
    const newTodoList = todoList.map(it => it.id === todo.id ? todo : it)
    await persistentToFile(newTodoList)
}

async function handleBulkDeleteTodo(idList) {
    if (!idList.length) {
        return
    }
    const todoList = await readFromFile()
    const newTodoList = todoList.filter(it => !idList.includes(it.id))
    await persistentToFile(newTodoList)
}

function parseJsonBody(req) {
    return new Promise(((resolve, reject) => {
        let data = '';
        req.on('data', chunk => {
            data += chunk;
        })
        req.on('end', () => {
            resolve(JSON.parse(data))
        })
        req.on('error', (err) => {
            reject(err)
        })
    }))
}

export default async function service(req, res) {
    try {
        const url = new URL(req.url, 'http://service/')
        const route = `${req.method} ${url.pathname}`
        switch (route) {
            case 'GET /':
                res.end('Todo MVC Service')
                break
            case 'GET /todo/list':
                const status = url.searchParams.get('status') ?? ''
                const todoList = await handleGetTodoList(status)
                res.setHeader('Content-Type', 'application/json')
                res.end(JSON.stringify(todoList))
                break
            case 'POST /todo':
                const { content } = await parseJsonBody(req) ?? {}
                const newTodo = await handleAddNewTodo(content)
                res.setHeader('Content-Type', 'application/json')
                res.end(JSON.stringify(newTodo))
                break
            case 'PUT /todo':
                const todo = await parseJsonBody(req)
                await handleUpdateTodo(todo)
                res.end()
                break
            case 'DELETE /todo':
                const idList = url.searchParams.getAll('id')
                    .map(id => Number(id))
                    .filter(id => !!id)
                await handleBulkDeleteTodo(idList)
                res.end()
                break
            default:
                res.statusCode = 404
                res.end('404 Not Found')
        }
    } catch (err) {
        res.statusCode = 400
        res.end('400 ' + err.message ?? 'Bad Request')
    }
}