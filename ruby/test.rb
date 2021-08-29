require 'json'
require 'net/http'
require_relative 'service'
require_relative 'store'

def assert expected, actual
    if expected != actual
        raise "Assertion Error: expected: #{expected}, actual: #{actual}"
    end
end

def add_todo content
    uri = URI 'http://localhost:8080/todo'
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = JSON.generate({ :content => content})
    res = Net::HTTP.start(uri.hostname, uri.port) do |http| http.request(req) end
    return JSON.parse(res.body)
end

def update_todo todo
    uri = URI 'http://localhost:8080/todo'
    req = Net::HTTP::Put.new(uri, 'Content-Type' => 'application/json')
    req.body = JSON.generate(todo)
    res = Net::HTTP.start(uri.hostname, uri.port) do |http| http.request(req) end
end

def get_todo_list status = ''
   uri = URI "http://localhost:8080/todo/list?status=#{status}"
   res = Net::HTTP.get_response uri
   return JSON.parse(res.body)
end

def delete_todo id_list
    qs = (id_list.map do |id| "id=#{id}" end).join '&'
    uri = URI "http://localhost:8080/todo?#{qs}"
    req = Net::HTTP::Delete.new uri
    res = Net::HTTP.start(uri.hostname, uri.port) do |http| http.request(req) end
end

def test
    assert 0, get_todo_list.length
    add_todo 'Todo'
    todo_list = get_todo_list
    assert 1, todo_list.length

    todo = todo_list[0]
    assert 'Todo', todo['content']
    assert 'active', todo['status']

    add_todo 'Another Todo'
    update_todo({ :id => todo['id'], :content => todo['content'], :status => 'completed' })
    assert 1, (get_todo_list 'completed').length
    assert 1, (get_todo_list 'active').length

    id_list = get_todo_list.map do |it| it['id'] end
    delete_todo id_list
    assert 0, get_todo_list.length
end

def run_test
    prune
    test
    prune
end

run_test
