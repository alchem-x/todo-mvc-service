require 'webrick'

def createServer(port)
    server = WEBrick::HTTPServer.new(
        :Port => port,
    )

    server.mount_proc '/' do |req, res|
      res.body = 'Todo MVC Service'
    end

    server
end