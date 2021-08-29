require 'webrick'
require 'json'
require_relative 'store'

class TodoListHandler < WEBrick::HTTPServlet::AbstractServlet

    def do_GET request, response
        status = request.query['status']

        response.status = 200
        response['Content-Type'] = 'application/json'
        response.body = self.get_todo_list status
    end

    def get_todo_list status
        todo_list = read_from_file
        if status === 'active' || status === 'completed'
            todo_list = todo_list.select do |it| it['status'] === status end
        end
        return JSON.generate todo_list
    end
end

class TodoHandler < WEBrick::HTTPServlet::AbstractServlet

    def do_POST request, response
        payload = JSON.parse(request.body)
        new_todo = self.add_new_todo payload['content']

        response.status = 200
        response['Content-Type'] = 'text/plain'
        response.body = JSON.generate new_todo
    end

    def do_PUT request, response
        payload = JSON.parse(request.body)
        self.update_todo payload

        response.status = 200
        response['Content-Type'] = 'text/plain'
        response.body = ''
    end

    def do_DELETE request, response
        id_list = self.parse_id_List(request.query_string)
        self.delete_todo id_list

        response.status = 200
        response['Content-Type'] = 'text/plain'
        response.body = ''
    end

    def add_new_todo content
        todo_list = read_from_file
        new_id = 1
        if(!todo_list.empty?)
           id_list = todo_list.map do |it| it['id'] end
           new_id = id_list.max + 1
        end
        new_todo = { :id => new_id, :content => content, :status => 'active' }
        todo_list << new_todo
        persistent_to_file todo_list
        return new_todo
    end

    def update_todo todo
        todo_list = read_from_file
        new_todo_list = todo_list.map do |it|
            if(it['id'] === todo['id'])
                { :id => todo['id'], :content => todo['content'], :status => todo['status']}
            else
                it
            end
        end
        persistent_to_file new_todo_list
    end

    def delete_todo id_list
        todo_list = read_from_file
        new_todo_list = todo_list.select do |it| !id_list.include? it['id'] end
        persistent_to_file new_todo_list
    end

    def parse_id_List query_string
        if query_string === ''
            return []
        end
        return (query_string.split '&').map do |it| (it.split '=')[1].to_i end
    end

end

def create_server(port)
    server = WEBrick::HTTPServer.new(:Port => port)

    server.mount_proc '/' do |req, res|
        res.body = 'Todo MVC Service'
    end

    server.mount '/todo/list', TodoListHandler
    server.mount '/todo', TodoHandler

    server
end