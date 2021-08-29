require 'json'

$store_file_filename = 'todo.json'

def read_from_file
    begin
        storeFile = File.new($store_file_filename, 'r')
        return JSON.load storeFile
    rescue
        return []
    end
end

def persistent_to_file todo_list
    File.open($store_file_filename, 'w') do |file|
      return JSON.dump(todo_list, file)
    end
end

def prune
    File.delete($store_file_filename) if File.exist?($store_file_filename)
end
