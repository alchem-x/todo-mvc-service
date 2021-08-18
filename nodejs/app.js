import http from 'http'
import service from './service.js'

const app = http.createServer(service)

app.listen(8080, () => {
    console.log('Todo MVC Service on :8080')
})
