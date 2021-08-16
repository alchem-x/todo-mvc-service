import json
from store import fetch, save
from sys import version as python_version
from cgi import parse_header, parse_multipart

if python_version.startswith('3'):
    from urllib.parse import parse_qs
    from http.server import BaseHTTPRequestHandler
else:
    from urlparse import parse_qs
    from BaseHTTPServer import BaseHTTPRequestHandler


def list_delete(todo_list, sid):
    index = None
    for i, item in enumerate(todo_list):
        if item['id'] == int(sid):
            index = i
            break
    return index


class Resquest(BaseHTTPRequestHandler):
    def header(self, code=200):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()

    def parse_post(self):
        ctype, pdict = parse_header(self.headers['content-type'])
        if ctype == 'multipart/form-data':
            post_data = parse_multipart(self.rfile, pdict)
        elif ctype == 'application/x-www-form-urlencoded':
            length = int(self.headers['content-length'])
            post_data = parse_qs(self.rfile.read(length), keep_blank_values=1)
        else:
            post_data = {}
        post_data = {str(k, encoding='utf8'): [str(v[0], encoding='utf8') for i in v] for k, v in post_data.items()}

        return post_data

    def do_GET(self):
        """
        /
        /todo/list?status=active
        :return:
        """
        if self.path == '/':
            self.header()
            data = "ok"
            self.wfile.write(json.dumps(data).encode())

        elif self.path.startswith("/todo/list"):
            self.header()
            params = self.query_params()
            print("params", params)
            data = fetch()
            if 'status' in params:
                data = [i for i in data if params['status'] == i['status']]

            self.wfile.write(json.dumps(data).encode())

        else:
            self.header(404)

    def do_POST(self):
        """
        data = {content:str}
        """
        if self.path == '/todo':
            self.header()
            post_data = self.parse_post()
            todo_list = fetch()
            if todo_list:
                todo_id = todo_list[-1]['id'] + 1
            else:
                todo_id = 0
            item = {'id': todo_id, 'content': post_data['content'][0], 'status': 'active'}
            todo_list.append(item)
            save(todo_list)
            self.wfile.write(json.dumps(item).encode())
        else:
            self.header(404)

    def do_PUT(self):
        """
        pout_data = {id:int,status:str}
        status:completed,active
        """
        if self.path == '/todo':
            self.header()
            put_data = self.parse_post()
            todo_list = fetch()
            todo_id = int(put_data['id'][0])
            item = todo_list[todo_id]
            item['status'] = put_data['status'][0]
            save(todo_list)
            self.wfile.write(json.dumps(item).encode())
        else:
            self.header(404)

    def do_DELETE(self):
        """
        delete /todo?id=1,2,3
        :return:
        """
        if self.path.startswith('/todo'):
            self.header()
            params = self.query_params()
            print("params", params)
            ids = params.get('id')
            done = []
            todo_list = fetch()
            for i in ids:
                index = list_delete(todo_list, i)
                if index is not None:
                    todo_list.pop(index)
                    done.append(index)
            save(todo_list)
            self.wfile.write(json.dumps(done).encode())
        else:
            self.header(404)

    def query_params(self):
        params = {}

        if "?" in self.path:
            query = self.path.split("?")[1].split("&")
            for q in query:
                k, v = q.split("=")
                if ',' in v:
                    v = v.split(',')
                params.update({k: v})

        return params
