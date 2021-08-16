import json

file_name = "todo.json"


def save(todo_list):
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