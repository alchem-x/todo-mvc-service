from http.server import HTTPServer

from service import Resquest

host = ('localhost', 8080)


if __name__ == '__main__':
    server = HTTPServer(host, Resquest)
    print("Starting server, listen at: %s:%s" % host)
    server.serve_forever()
