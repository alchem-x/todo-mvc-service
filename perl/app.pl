#!/usr/bin/perl

use strict;
use warnings;

#use CGI qw/ :standard /;
use Data::Dumper;
use HTTP::Daemon;
use HTTP::Response;
use HTTP::Status;
use JSON;
use POSIX qw/ WNOHANG /;

use constant HOSTNAME => qx{hostname};

my %O = (
    'listen-host' => '127.0.0.1',
    'listen-port' => 8080,
    'listen-clients' => 2,
    'listen-max-req-per-child' => 100,
);

my $d = HTTP::Daemon->new(
    LocalAddr => $O{'listen-host'},
    LocalPort => $O{'listen-port'},
    Reuse => 1,
) or die "Can't start http listener at $O{'listen-host'}:$O{'listen-port'}";

print "Started HTTP listener at " . $d->url . "\n";

my %chld;

if ($O{'listen-clients'}) {
    $SIG{CHLD} = sub {
        # checkout finished children
        while ((my $kid = waitpid(-1, WNOHANG)) > 0) {
            delete $chld{$kid};
        }
    };
}

while (1) {
    if ($O{'listen-clients'}) {
        # prefork all at once
        for (scalar(keys %chld) .. $O{'listen-clients'} - 1 ) {
            my $pid = fork;

            if (!defined $pid) { # error
                die "Can't fork for http child $_: $!";
            }
            if ($pid) { # parent
                $chld{$pid} = 1;
            }
            else { # child
                $_ = 'DEFAULT' for @SIG{qw/ INT TERM CHLD /};
                http_child($d);
                exit;
            }
        }

        sleep 1;
    }
    else {
        http_child($d);
    }

}

sub http_child {
    my $d = shift;

    my $i;

    while (++$i < $O{'listen-max-req-per-child'}) {
        my $c = $d->accept or last;
        my $r = $c->get_request(1) or last;
        $c->autoflush(1);

        print sprintf("[%s] %s %s\n", $c->peerhost, $r->method, $r->uri->as_string);

        my %FORM = $r->uri->query_form();

        if ($r->uri->path eq '/') {

        }
        elsif ($r->uri->path eq '/ping') {
            _http_response($c, { content_type => 'application/json' }, "pong");
        }
        else {
            _http_error($c, RC_NOT_FOUND);
        }

        $c->close();
        undef $c;
    }
}

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
