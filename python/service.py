import json
import store
from cgi import parse_header, parse_multipart

from urllib.parse import parse_qs
from http.server import BaseHTTPRequestHandler


class Resquest(BaseHTTPRequestHandler):
    def url_format(self):
        self.url = self.path.split("?")[0]
        return self.url

    def header(self, code=200):
        self.send_response(code)
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
        post_data = {str(k, encoding='utf8'): [str(i, encoding='utf8') for i in v] for k, v in post_data.items()}

        return post_data

    def do_GET(self):
        """
        /
        /todo/list?status=active
        :return:
        """
        self.url_format()

        if self.url == '/':
            self.header()
            data = "ok"
            self.wfile.write(json.dumps(data).encode())

        elif self.url == "/todo/list":
            self.header()
            params = self.query_params()
            data = store.fetch()
            if 'status' in params:
                data = [i for i in data if params['status'] == i['status']]

            self.wfile.write(json.dumps(data).encode())

        else:
            self.header(404)

    def do_POST(self):
        """
        data = {content:str}
        """
        self.url_format()

        if self.url == '/todo':
            self.header()
            post_data = self.parse_post()
            item = store.create(post_data['content'][0])
            self.wfile.write(json.dumps(item).encode())
        else:
            self.header(404)

    def do_PUT(self):
        """
        pout_data = {id:int,content:str, status:str}
        status:completed,active
        """
        self.url_format()

        if self.url == '/todo':
            self.header()
            put_data = self.parse_post()
            data = {
                'id': int(put_data['id'][0]),
                'content': put_data['content'][0],
                'status': put_data['status'][0],
            }
            item = store.update(data)
            self.wfile.write(json.dumps(item).encode())
        else:
            self.header(404)

    def do_DELETE(self):
        """
        delete /todo?id=1,2,3
        """
        self.url_format()

        if self.url == '/todo':
            self.header()
            params = self.query_params()
            ids = params.get('id')
            done = store.delete([int(i) for i in ids])
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
