import { promises as fs } from 'fs'

const filename = 'todo.json'

export async function readFromFile() {
    try {
        return JSON.parse((await fs.readFile(filename)).toString('utf8'))
    } catch (err) {
        if (err.code === 'ENOENT') {
            return []
        } else {
            throw err
        }
    }
}

export async function persistentToFile(todoList) {
    await fs.writeFile(filename, JSON.stringify(todoList))
}

