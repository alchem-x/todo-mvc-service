unit class Service;
use strict;
use Bailador;
use Store;

app.config.default-content-type = 'application/json';

get '/' => sub {
    my %person =
        name => 'Foo',
        id   => 42,
        courses => ['Perl', 'Web Development'],
    ;
    return to-json %person;
};

get '/ping' => sub {
    return "pong";
};

get '/todo/list' => sub {
    my $status = '';
    if request.params{'status'}:exists {
        $status = request.params<status>;
    }
    my $store = Store::Action.new();
    my @list = $store.list();
    my @filter_list;

    if $status eq '' {
        return to-json @list
    }

    for @list -> %item {
      if %item<status> eq $status {
            @filter_list.push(%item);
        }
    }
    say @filter_list;
    return to-json @filter_list;
};

post '/todo' => sub {
    my $content = request.params<content>;
    my $store = Store::Action.new();
    my @list = $store.list();
    my %item = (id => @list.tail<id> + 1, content => $content, status => 'active');
    $store.add(%item);
    return to-json %item;
};

put '/todo' => sub {
    my $id = request.params<id>;
    my $content = request.params<content>;
    my $status = request.params<status>;
    my %item = (id => $id, content => $content, status => $status);
    my $store = Store::Action.new();
    $store.update(%item);
    return to-json %item;
};

delete '/todo' => sub {
    my $id = request.params<id>;
    my $store = Store::Action.new();
    my @ids = split(",", $id);
    for @ids -> $id {
        $store.delete($id.Numeric);
    }
    return $id;
};


