#$Id: prereq.t,v 1.3 2004/09/03 02:24:15 comdog Exp $
use Test::More;
eval "use Test::Prereq 1.0";
plan skip_all => "Test::Prereq required to test dependencies" if $@;
prereq_ok();
