import fs from 'fs/promises'

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

export async function prune() {
    try {
        await fs.rm(filename)
    } catch (err) {
        if (err.code !== 'ENOENT') {
            throw err
        }
    }
}