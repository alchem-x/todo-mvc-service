require 'net/http'
require_relative 'service'

uri = URI 'http://localhost:8080/todo/list'
res = Net::HTTP.get_response uri
