# $Id: load.t 1270 2004-07-04 17:56:42Z comdog $
BEGIN {
	@classes = qw(Test::File);
	}

use Test::More tests => scalar @classes;

foreach my $class ( @classes )
	{
	print "bail out! $class did not compile!" unless use_ok( $class );
	}
