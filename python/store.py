import pickle

file_name = "pickle.pkl"


def save(todo_list):
    with open(file_name, 'wb') as f:
        pickle.dump(todo_list, f)


def fetch():
    with open(file_name, 'rb') as f:
        todo_list = pickle.load(f)
        return todo_list