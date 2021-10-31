# Todo MVC Service

- See: [TodoMVC](https://todomvc.com/)
- See: [Todo-Backend](https://todobackend.com/)

## Progress

- [ ] C
- [ ] C#
- [ ] C++
- [ ] Go
- [x] Java
- [x] Node.js
- [x] Perl6
- [x] Perl5
- [ ] PHP
- [x] Python
- [x] Ruby
- [ ] Rust
- [ ] Swift

## API

### Get Todo List

GET `/todo/list`

#### URL Search Params

- `?status=`: Get all todo
- `?status=active`: Get active todo
- `?status=completed`: Get completed todo

#### Response Body

- Content-Type: `application/json`

```json
[
  {
    "id": 1,
    "content": "Todo 1",
    "status": "active"
  },
  {
    "id": 2,
    "content": "Todo 2",
    "status": "completed"
  }
]
```

---

### Create New Todo

POST `/todo`

#### Request Body

- Content-Type: `application/json`

```json
{
  "content": "Todo 2"
}
```

---

### Update Todo

PUT `/todo`

#### Request Body

- Content-Type: `application/json`

```json
{
  "id": 1,
  "content": "Todo 1",
  "status": "completed"
}
```

---

### Delete Todo

DELETE `/todo`

#### URL Search Params

- `?id=1&id=2`: Delete specific todo by ID
