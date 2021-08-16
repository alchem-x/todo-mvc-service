import json

file_name = "todo.json"


def save(todo_list):
    """
    item: {'id': int, 'content': str, 'status': str}
    :param todo_list: [item]
    """
    with open(file_name, 'w') as f:
        json.dump(todo_list, f)


def fetch():
    try:
        with open(file_name, 'r') as f:
            todo_list = json.load(f)
            return todo_list
    except Exception as ee:
        print(ee)
    return []


def create(content):
    todo_list = fetch()
    if todo_list:
        todo_id = todo_list[-1]['id'] + 1
    else:
        todo_id = 0
    item = {'id': todo_id, 'content': content, 'status': 'active'}
    todo_list.append(item)
    save(todo_list)
    return item


def update(data):
    todo_list = fetch()
    todo_id = data['id']
    item = todo_list[todo_id]
    item.update(data)
    save(todo_list)
    return item


def delete(data):
    done = []
    todo_list = fetch()
    for i in data:
        index = __list_delete(todo_list, i)
        if index is not None:
            todo_list.pop(index)
            done.append(index)
    save(todo_list)
    return done


def __list_delete(todo_list, sid):
    index = None
    for i, item in enumerate(todo_list):
        if item['id'] == int(sid):
            index = i
            break
    return index
