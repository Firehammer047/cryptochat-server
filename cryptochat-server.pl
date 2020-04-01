#!/usr/bin/perl
#
# Copyright (c) GB Tony Cabrera (firehammer047) 2015
#

use strict;

use IO::Socket::INET;

my $DEBUG = 1;

my $HOST = '192.168.1.221';
#my $HOST = '192.168.1.102';

# creating a listening socket
my $socket = new IO::Socket::INET (
	LocalHost => $HOST,
	LocalPort => '6969',
	Proto => 'tcp',
	Listen => 5,
	Reuse => 1
);
die "cannot create socket $!\n" unless $socket;
print "Listening on $HOST ...\n\n";

my $inbox;

while(1){
	# waiting for a new client connection
	my $client_socket = $socket->accept();

	# get information about a newly connected client
#	my $client_address = $client_socket->peerhost();
#	my $client_port = $client_socket->peerport();
#	print "Connection from $client_address:$client_port\n";
	print "Connection received.\n";
	
	my $from = "";
	my $to = "";

	my $len1 = "";
	my $len2 = "";
	$client_socket->recv($len1, 1);
	$client_socket->recv($len2, 1);
	printf "Length bytes: %vd %vd\n", $len1, $len2;
	
	# read from the connected client
	my $message = "";
	my $data = "";
	if ($DEBUG){ print "Data: "; }
	my $l1 = ord $len1;
	my $l2 = ord $len2;
	my $l = $l1 + $l2;
	if ($l2>0){ $l += 255; }

	for(my $i = 0; $i<$l; $i++){
		$client_socket->recv($data, 1);
		if($DEBUG){ printf "%vx", $data; }
		$message .= $data;
	}
	
	print "\n";

	(my $header, my $cipher) = split('#!', $message);
	(my $from, my $to) = split(':', $header);

	$inbox->{$to}->{$from} = $cipher;
	
	if($DEBUG){
		print $to."'s inbox: ";
		printf "%v02x", $inbox->{$to}->{$from};
		print "\n";
	}


	# write response data to the connected client
	$data = "OK";
	$client_socket->send($data);

	# notify client that response has been sent
	shutdown($client_socket, 1);
	print "Disconnected. \n\n";
}

$socket->close();
