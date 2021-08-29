require_relative 'service'

server = create_server 8080

trap 'INT' do server.shutdown end

server.start
