#$Id: prereq.t,v 1.2 2004/01/22 00:37:47 comdog Exp $
use Test::More;
eval "use Test::Prereq";
plan skip_all => "Test::Prereq required to test dependencies" if $@;
prereq_ok();
