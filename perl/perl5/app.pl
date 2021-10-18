#!/usr/bin/perl

# use service;

my %settings = (
    'host' => '127.0.0.1',
    'port' => 8080,
);


sub run_server(){
    print "Started HTTP listener at " . $settings{'host'} . ':' . $settings{'port'} . "\n";
    my $server = $settings{'host'};
    my $port = $settings{'port'};
    my $proto = getprotobyname('tcp');

    socket(SOCKET, PF_INET, SOCK_STREAM, $proto) or die "无法打开 socket $!\n";
    setsockopt(SOCKET, SOL_SOCKET, SO_REUSEADDR, 1) or die "无法设置 SO_REUSEADDR $!\n";
    bind( SOCKET, pack_sockaddr_in($port, inet_aton($server))) or die "无法绑定端口 $port! \n";

    listen(SOCKET, 5) or die "listen: $!";

    my $client_addr;
    while ($client_addr = accept(NEW_SOCKET, SOCKET)) {
       # send them a message, close connection
       my $name = gethostbyaddr($client_addr, AF_INET );
       print NEW_SOCKET "我是来自服务端的信息";
       print "Connection recieved from $name\n";
       close NEW_SOCKET;
    }
    # while (1) {
    #     service::http_child($daemon);
    # }
}

run_server();