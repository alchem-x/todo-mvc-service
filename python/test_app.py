import requests


def ok():
    url = 'http://localhost:8080/'
    res = requests.get(url).json()
    print(res)
    print("="*100)


def get_list():
    url = 'http://localhost:8080/todo/list'
    res = requests.get(url).json()
    print(res)
    print("="*100)


def get_list_query(status='active'):
    url = f'http://localhost:8080/todo/list?status={status}'
    res = requests.get(url).json()
    print(res)
    print("="*100)


def create(act):
    url = f'http://localhost:8080/todo'
    data = {'content': act}
    res = requests.post(url, data=data).json()
    print(res)
    print("="*100)


def update_status(todo_id):
    url = f'http://localhost:8080/todo'
    data = {'id': todo_id, 'status': 'completed'}
    res = requests.put(url, data=data).json()
    print(res)
    print("="*100)


def delete(ids):
    url = f'http://localhost:8080/todo?id={ids}'
    res = requests.delete(url).json()
    print(res)
    print("="*100)


def main():
    ok()
    create('eat')
    create('sleep')
    create('work')
    get_list()
    get_list_query('active')
    update_status(2)
    get_list()
    get_list_query('active')
    delete(1)


if __name__ == '__main__':
    main()
