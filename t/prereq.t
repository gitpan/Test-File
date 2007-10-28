#$Id: prereq.t 1642 2005-06-05 13:23:56Z comdog $
use Test::More;
eval "use Test::Prereq 1.0";
plan skip_all => "Test::Prereq required to test dependencies" if $@;
prereq_ok( undef, undef, [ qw(t/setup_common) ] );
