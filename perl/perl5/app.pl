#!/usr/bin/perl
package WebServer;

use HTTP::Server::Simple::CGI;
use base qw(HTTP::Server::Simple::CGI);
use Service;
use JSON;

sub handle_request {
    my ($self, $cgi) = @_;
    my $handler = \&resp_info;

    print "HTTP/1.0 200 OK\r\n";
    print $cgi->header(
    -type    => 'application/json',
    -status  => '200',
    );
    $handler->($cgi);
}

sub resp_info {
    my $cgi = shift;
    return if !ref $cgi;

    my $json = request_handler->($cgi);
    print $cgi->param(
        -name  => 'data',
        -value => $json,
        );
};

sub request_handler(){
    my $cgi = shift;
    my $path = $cgi->path_info();
    my $method = $cgi->request_method();
    if ( '/ping' eq $path && $method eq 'GET' ) {
        # return ("ping"=>"pong");
        return to_json 'pong';
    }elsif ( '/todo/list' eq $path && $method eq 'GET' ) {
        my @res = Service::get_todo_list();
        return to_json \@res;
    }elsif ( '/todo' eq $path && $method eq 'POST' ) {
        my %item = Service->add_todo_list($cgi->param(-name=>'content'));
        return to_json \%item;
    }elsif ( '/todo' eq $path && $method eq 'PUT' ) {
        my $id = $cgi->param(-name=>'id');
        my $content = $cgi->param(-name=>'content');
        my $status = $cgi->param(-name=>'status');
        my %item = Service->update_todo_list($id, $content, $status);
        return to_json \%item;
    }elsif ( '/todo' eq $path && $method eq 'DELETE' ) {
        my $id = $cgi->param(-name=>'id');
        my @res = Service->delete_todo_list($id);
        return to_json \@res;
    }else{
        return to_json "ok";
    }
}

WebServer->new(8080)->run();