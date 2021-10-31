package Store;
use JSON;

my $file_name = "todo.json";

sub read_file{
    open(DATA, "<", $file_name) or die "todo.json file open failed,$!";
    my $str="";
    while(<DATA>){
        $str = "$str$_";
    }
    my @lines=@{decode_json($str)};
    close(DATA) || die "无法关闭文件";
    return @lines;
}

sub save_file{
    my @lines = @_;
    my $todo_str = to_json \@lines;
    open(DATA, ">", $file_name) or die "todo.json file open failed,$!";
    print DATA $todo_str;
    close(DATA);
}

sub add{
    my $item = shift;
    my @lines = read_file();
    push(@lines, $item);
    save_file(@lines);
}

sub list{
    return read_file();
}

sub update{
    my $uitem=shift;
    my @lines = read_file();
    foreach $item(@lines) {
        if ($item->{"id"} == $uitem->{"id"}) {
            $item->{"content"} = $uitem->{"content"};
            $item->{"status"} = $uitem->{"status"};
        }
    }
    save_file(@lines);
}

sub delete{
    my @lines = read_file();
    my @ids = @_;
    my $flag = 1;
    my @valid = ();
    my @new_lines = ();
    for $item(@lines) {
        for $id(@ids) {
            if ($item->{'id'} == $id) {
                $flag=0;
                push(@valid, $id);
                last;
            }
        }
        if ($flag == 1) {
            push(@new_lines, $item);
        }
        $flag=1;
    }
    # print "valid:@valid\n";
    # print "new_lines:@new_lines\n";
    save_file(@new_lines);
    return @valid;
}
1;
