# $Id: links.t,v 1.1 2005/10/02 10:41:47 comdog Exp $
use strict;

use Test::Builder::Tester;
use Test::More tests => 24;
use Test::File;

=pod

max_file       non_zero_file  not_readable   readable       zero_file
executable     min_file       not_executable not_writeable  writeable

=cut

my $can_symlink = eval { symlink("",""); 1 };

my $test_directory = 'test_files';
SKIP: {
    skip "This system does't do symlinks", 5 unless $can_symlink;
    require "t/setup_common";
};
