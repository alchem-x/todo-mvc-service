unit module Store;
use JSON::Fast;
#
# [
#   {
#     "id": 1,
#     "content": "Todo 1",
#     "status": "active"
#   },
#   {
#     "id": 2,
#     "content": "Todo 2",
#     "status": "completed"
#   }
# ]
my $file_name = "todo.json";


class Action{
    method save_file($todo_list){
        my $result = to-json($todo_list);
        say $result;
        spurt $file_name, $result;
    }
    method read_file{
        my @lines;
        try {
            my $data = slurp $file_name;
            @lines = from-json($data);
            CATCH {
                default {
                    say "read file error $_" ;
                }
            }
        };
        say @lines;
        return @lines;
    }
    method add($item){
        my @lines = self.read_file();
        push(@lines, $item);
        self.save_file(@lines);
    }

    method list{
        return self.read_file();
    }

    method update(%uitem){
        my @lines = self.read_file();
        for @lines -> %item {
            if %item<id> == %uitem<id> {
                %item<content> = %uitem<content>;
                %item<status> = %uitem<status>;
            }
        }
        # @lines[$index] = $item;
        self.save_file(@lines);
    }

    method delete($index){
        my @lines = self.read_file();
        @lines.splice($index,1);
        self.save_file(@lines);
    }

}

