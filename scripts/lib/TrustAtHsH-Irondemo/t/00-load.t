#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'TrustAtHsH::Irondemo' ) || print "Bail out!\n";
}

diag( "Testing TrustAtHsH::Irondemo $TrustAtHsH::Irondemo::VERSION, Perl $], $^X" );
