import json
from http.server import BaseHTTPRequestHandler
from store import fetch


class Resquest(BaseHTTPRequestHandler):
    def header(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()

    def do_GET(self):
        self.header()
        data = {}
        if self.path == '/':
            data = "ok"
        if self.path == "/todo/list":
            data = fetch()

        self.wfile.write(json.dumps(data).encode())

    def do_POST(self):
        self.header()
        data = {}
        if self.path == '/todo':
            data = "post"

        self.wfile.write(json.dumps(data).encode())

    def do_PUT(self):
        self.header()
        data = {}
        if self.path == '/todo':
            data = "put"

        self.wfile.write(json.dumps(data).encode())

    def do_DELETE(self):
        self.header()
        data = {}
        if self.path == '/todo':
            data = "delete"

        self.wfile.write(json.dumps(data).encode())
