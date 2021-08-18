require_relative 'service'

server = createServer 8080

trap 'INT' do server.shutdown end

server.start

# puts 'Todo MVC Service on :8080'
