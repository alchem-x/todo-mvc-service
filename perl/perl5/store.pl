use strict;
package store;

my $file_name = "todo.json";

sub read_file{
    my @lines;
    open(data, "<", $file_name) or die "todo.json file open failed,$!";
    @lines=<data>;
    close(data);
    return @lines;
}

sub save_file{
    my @list = @_;
    my $todo_str = join("\n", @list);
    open(data, ">", $file_name) or die "todo.json file open failed,$!";
    print data ($todo_str);
    close(data);
}

sub create{
    my @lines;
    my $item;

    @lines = read_file();
    $item = join(",", @_);
    push(@lines, $item);
    save_file(@lines);
}

sub list{
    return read_file();
}

sub update{
    my @lines;
    my $item;
    @lines = read_file();
    $item = join(",", @_);


    return
}

sub delete{

}
