#!/usr/bin/perl
use LWP::UserAgent;
use Math::BigSimple; # Module written by myself
use Math::BigInt; # Module from standard Perl distribution
my $agent = LWP::UserAgent->new();
my $generator = Math::BigSimple->new( 'Length' => 8 );

my $Q = $generator->make();                     # Simple number
my $A = int($Q - rand() * $Q) - 1;
my $X = int($A - rand() * $A) - 1;              # Client secret key
my $tmp_big_A = Math::BigInt->new($A);
my $tmp_big_X = Math::BigInt->new($X);
my $tmp_big_Q = Math::BigInt->new($Q);
my $tmp_big_Y = $tmp_big_A->bmodpow($X, $Q);
my $Y = $tmp_big_Y->bstr();                     # Client public key

$REQUEST = "A=$A&Q=$Q&Y=$Y";


my $rq = HTTP::Request->new('GET' => "http://$ARGV[0]:10001/$REQUEST");
my $rs = $agent->request($rq);
my $peer_Y = Math::BigInt->new($rs->content());
my $RESULT = $peer_Y->bmodpow($tmp_big_X, $Q);  # Result found

print "Digital key exchanged, result is '$RESULT\'.\n";
