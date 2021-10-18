package service;

use HTTP::Response;
use HTTP::Status;

use store;


sub _http_error {
    my ($c, $code, $msg) = @_;
    $c->send_error($code, $msg);
}

sub _http_response {
    my $c = shift;
    my $options = shift;

    $c->send_response(
        HTTP::Response->new(
            RC_OK,
            undef,
            [
                'Content-Type' => $options->{content_type},
                'Cache-Control' => 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0',
                'Pragma' => 'no-cache',
                'Expires' => 'Thu, 01 Dec 1994 16:00:00 GMT',
            ],
            join("\n", @_),
        )
    );
}

sub http_child {
    my $daemon = shift;
    my $c = $daemon->accept or last;
    my $r = $c->get_request(1) or last;

    $c->autoflush(1);

    print sprintf("[%s] %s %s\n", $c->peerhost, $r->method, $r->uri->as_string);

    my %FORM = $r->uri->query_form();

    if ($r->uri->path eq '/todo/list') {

    }
    elsif ($r->uri->path eq '/todo/list') {

    }
    elsif ($r->uri->path eq '/ping') {
        _http_response(
            $c,
            { content_type => 'application/json' },
            "pong"
        );
    }
    else {
        _http_error($c, RC_NOT_FOUND);
    }

    $c->close();
    undef $c;
}

sub router_handler{
    my $url = shift;
    my @url_arr = split /?status=/,$url;


}

sub do_post{

    store::create();
}

sub do_get{

}

sub do_put{

}

sub do_delete{

}
