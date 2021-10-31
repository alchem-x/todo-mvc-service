package Service;
use Store;


sub get_todo_list {
    return Store::list();
}

sub add_todo_list {
    my $self = shift;
    my $content = shift;
    my @list = Store::list();
    my $litem = $list[-1];
    my %item = (id => $litem->{'id'} + 1, content => $content, status => 'active');
    Store::add(\%item);
    return %item;
}

sub update_todo_list(){
    my $self = shift;
    my $id = shift;
    my $content = shift;
    my $status = shift;
    my %item = (id => $id+0, content => $content, status => $status);
    Store::update(\%item);
    return %item;
}

sub delete_todo_list(){
    my $self = shift;
    my $id  = shift;
    my @ids = split(",", $id);
    return Store::delete(@ids);
}

1;