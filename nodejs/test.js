import fetch from 'node-fetch'

const response = await fetch('http://localhost:8080/todo/list')
const todoList = await response.json()
