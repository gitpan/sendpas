#!/usr/bin/perl

use HTTP::Daemon;
use Math::BigInt;

my $d = HTTP::Daemon->new(
	LocalPort => 10001
) or die;

while(my $c = $d->accept())
{
	while(my $r = $c->get_request())
	{
		$REQUEST = $r->uri();
		substr($REQUEST, 0, 1, "");

		# Decoding request
		my @pairs = split(/\&/, $REQUEST);
		my %rq_info;
		foreach (@pairs)
		{
			my($key, $val) = split(/\=/, $_);
			$rq_info{$key} = $val;
		}

		# Generating server keys & result key.
		my $Q = $rq_info{Q};
		my $A = $rq_info{A};
		my $peer_Y = Math::BigInt->new($rq_info{Y});
		my $X = int($A - rand() * $A) - 1;                 # Server secret key
		my $tmp_big_A = Math::BigInt->new($A);
		my $tmp_big_X = Math::BigInt->new($X);
		my $tmp_big_Q = Math::BigInt->new($Q);
		my $tmp_big_Y = $tmp_big_A->bmodpow($X, $Q);
		my $Y = $tmp_big_Y->bstr();                        # Server public key
		my $RESULT = $peer_Y->bmodpow($tmp_big_X, $Q);     # Result found

		print "Digital key exchanged, result is '$RESULT\'.\n";

		# Sending response(with server public key).
		my $h = HTTP::Headers->new;
		my $r = HTTP::Response->new(200, "ok", $h, $Y);

		$c->send_response($r);
	}
	$c -> close;
	undef($c);
}
