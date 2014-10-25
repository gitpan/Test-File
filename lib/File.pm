# $Id: File.pm,v 1.8 2005/01/06 23:35:52 comdog Exp $
package Test::File;
use strict;

use base qw(Exporter);
use vars qw(@EXPORT $VERSION);

use File::Spec;
use Test::Builder;

@EXPORT = qw(
	file_exists_ok file_not_exists_ok
	file_empty_ok file_not_empty_ok file_size_ok file_max_size_ok
	file_min_size_ok file_readable_ok file_not_readable_ok file_writeable_ok
	file_not_writeable_ok file_executable_ok file_not_executable_ok
	file_mode_is file_mode_isnt
	);

$VERSION = sprintf "%d.%02d", q$Revision: 1.8 $ =~ /(\d+)\.(\d+)/;

my $Test = Test::Builder->new();

=head1 NAME

Test::File -- test file attributes

=head1 SYNOPSIS

use Test::File;

=head1 DESCRIPTION

This modules provides a collection of test utilities for
file attributes.

Some file attributes depend on the owner of the process testing
the file in the same way the file test operators do.  For instance,
root (or super-user or Administrator) may always be able to read
files no matter the permissions.  

Some attributes don't make sense outside of Unix, either, so
some tests automatically skip if they think they won't work on
the platform.  If you have a way to make these functions work
on Windows, for instance, please send me a patch. :)

=head2 Functions

=cut

sub _normalize
	{
	my $file = shift;
	
	return $file =~ m|/|
		? File::Spec->catfile( split m|/|, $file )
		: $file;
	}
	
sub _win32
	{
	return $^O =~ m/Win/;
	}
	
=over 4

=item file_exists_ok( FILENAME [, NAME ] )

Ok if the file exists, and not ok otherwise.

=cut

sub file_exists_ok($;$)
	{
	my $filename = _normalize( shift );
	my $name     = shift || "$filename exists";

	my $ok = -e $filename;

	if( $ok )
		{
		$Test->ok(1, $name);
		}
	else
		{
		$Test->diag("File [$filename] does not exist");
		$Test->ok(0, $name);
		}
	}

=item file_not_exists_ok( FILENAME [, NAME ] )

Ok if the file does not exist, and not okay if it does exist.

=cut

sub file_not_exists_ok($;$)
	{
	my $filename = _normalize( shift );
	my $name     = shift || "$filename does not exist";

	my $ok = not -e $filename;

	if( $ok )
		{
		$Test->ok(1, $name);
		}
	else
		{
		$Test->diag("File [$filename] exists");
		$Test->ok(0, $name);
		}
	}

=item file_empty_ok( FILENAME [, NAME ] )

Ok if the file exists and has empty size, not ok if the
file does not exist or exists with non-zero size.

=cut

sub file_empty_ok($;$)
	{
	my $filename = _normalize( shift );
	my $name     = shift || "$filename is empty";

	my $ok = -z $filename;

	if( $ok )
		{
		$Test->ok(1, $name);
		}
	else
		{
		if( -e $filename )
			{
			my $size = -s $filename;
			$Test->diag( 'File exists with non-zero size [$size] b');
			}
		else
			{
			$Test->diag( 'File does not exist');
			}

		$Test->ok(0, $name);
		}
	}

=item file_not_empty_ok( FILENAME [, NAME ] )

Ok if the file exists and has non-zero size, not ok if the
file does not exist or exists with zero size.

=cut

sub file_not_empty_ok($;$)
	{
	my $filename = _normalize( shift );
	my $name     = shift || "$filename is not empty";

	my $ok = not -z $filename;

	if( $ok )
		{
		$Test->ok(1, $name);
		}
	else
		{
		if( -e $filename and -z $filename )
			{
			$Test->diag( 'File [$filename] exists with zero size');
			}
		else
			{
			$Test->diag( 'File [$filename] does not exist');
			}

		$Test->ok(0, $name);
		}
	}

=item file_size_ok( FILENAME, SIZE [, NAME ]  )

Ok if the file exists and has SIZE size in bytes (exactly), not ok if
the file does not exist or exists with size other than SIZE.

=cut

sub file_size_ok($$;$)
	{
	my $filename = _normalize( shift );
	my $expected = int shift;
	my $name     = shift || "$filename has right size";

	my $ok = ( -s $filename ) == $expected;

	if( $ok )
		{
		$Test->ok(1, $name);
		}
	else
		{
		unless( -e $filename )
			{
			$Test->diag( 'File [$filename] does not exist');
			}
		else
			{
			my $actual = -s $filename;
			$Test->diag( 'File [$filename] has actual size [$actual] not [$expected]');
			}

		$Test->ok(0, $name);
		}
	}

=item file_max_size_ok( FILENAME, MAX [, NAME ] )

Ok if the file exists and has size less than or equal to MAX bytes, not
ok if the file does not exist or exists with size greater than MAX
bytes.

=cut

sub file_max_size_ok($$;$)
	{
	my $filename = _normalize( shift );
	my $max      = int shift;
	my $name     = shift || "$filename is under $max bytes";

	my $ok = ( -s $filename ) <= $max;

	if( $ok )
		{
		$Test->ok(1, $name);
		}
	else
		{
		unless( -e $filename )
			{
			$Test->diag( 'File [$filename] does not exist');
			}
		else
			{
			my $actual = -s $filename;
			$Test->diag( 'File [$filename] has actual size [$actual] greater than [$max]');
			}

		$Test->ok(0, $name);
		}
	}

=item file_min_size_ok( FILENAME, MIN [, NAME ] )

Ok if the file exists and has size greater than or equal to MIN bytes,
not ok if the file does not exist or exists with size less than MIN
bytes.

=cut

sub file_min_size_ok($$;$)
	{
	my $filename = _normalize( shift );
	my $min      = int shift;
	my $name     = shift || "$filename is over $min bytes";

	my $ok = ( -s $filename ) >= $min;

	if( $ok )
		{
		$Test->ok(1, $name);
		}
	else
		{
		unless( -e $filename )
			{
			$Test->diag( 'File [$filename] does not exist');
			}
		else
			{
			my $actual = -s $filename;
			$Test->diag( 'File [$filename] has actual size [$actual] less than [$min]');
			}

		$Test->ok(0, $name);
		}
	}

=item file_readable_ok( FILENAME [, NAME ] )

Ok if the file exists and is readable, not ok
if the file does not exist or is not readable.

=cut

sub file_readable_ok($;$)
	{
	my $filename = _normalize( shift );
	my $name     = shift || "$filename is readable";

	my $ok = -r $filename;

	if( $ok )
		{
		$Test->ok(1, $name);
		}
	else
		{
		$Test->diag("File [$filename] is not readable");
		$Test->ok(0, $name);
		}
	}

=item file_not_readable_ok( FILENAME [, NAME ] )

Ok if the file exists and is not readable, not ok
if the file does not exist or is readable.

=cut

sub file_not_readable_ok($;$)
	{
	my $filename = _normalize( shift );
	my $name     = shift || "$filename is not readable";

	my $ok = not -r $filename;

	if( $ok )
		{
		$Test->ok(1, $name);
		}
	else
		{
		$Test->diag("File [$filename] is readable");
		$Test->ok(0, $name);
		}
	}

=item file_writeable_ok( FILENAME [, NAME ] )

Ok if the file exists and is writeable, not ok
if the file does not exist or is not writeable.

=cut

sub file_writeable_ok($;$)
	{
	my $filename = _normalize( shift );
	my $name     = shift || "$filename is writeable";

	my $ok = -w $filename;

	if( $ok )
		{
		$Test->ok(1, $name);
		}
	else
		{
		$Test->diag("File [$filename] is not writeable");
		$Test->ok(0, $name);
		}
	}

=item file_not_writeable_ok( FILENAME [, NAME ] )

Ok if the file exists and is not writeable, not ok
if the file does not exist or is writeable.

=cut

sub file_not_writeable_ok($;$)
	{
	my $filename = _normalize( shift );
	my $name     = shift || "$filename is not writeable";

	my $ok = not -w $filename;

	if( $ok )
		{
		$Test->ok(1, $name);
		}
	else
		{
		$Test->diag("File [$filename] is writeable");
		$Test->ok(0, $name);
		}
	}

=item file_executable_ok( FILENAME [, NAME ] )

Ok if the file exists and is executable, not ok
if the file does not exist or is not executable.

This test automatically skips if it thinks it is on a
Windows platform.

=cut

sub file_executable_ok($;$)
	{
    if( _win32() )
		{
		$Test->skip( "file_executable_ok doesn't work on Windows" );
		return;
		}

	my $filename = _normalize( shift );
	my $name     = shift || "$filename is executable";

	my $ok = -x $filename;

	if( $ok )
		{
		$Test->ok(1, $name);
		}
	else
		{
		$Test->diag("File [$filename] is not executable");
		$Test->ok(0, $name);
		}
	}

=item file_not_executable_ok( FILENAME [, NAME ] )

Ok if the file exists and is not executable, not ok
if the file does not exist or is executable.

This test automatically skips if it thinks it is on a
Windows platform.

=cut

sub file_not_executable_ok($;$)
	{
	if( _win32() )
		{
		$Test->skip( "file_not_executable_ok doesn't work on Windows" );
		return;
		}

	my $filename = _normalize( shift );
	my $name     = shift || "$filename is not executable";

	my $ok = not -x $filename;

	if( $ok )
		{
		$Test->ok(1, $name);
		}
	else
		{
		$Test->diag("File [$filename] is executable");
		$Test->ok(0, $name);
		}
	}

=item file_mode_is( FILENAME, MODE [, NAME ] )

Ok if the file exists and the mode matches, not ok
if the file does not exist or the mode does not match.

This test automatically skips if it thinks it is on a
Windows platform.

Contributed by Shawn Sorichetti <ssoriche@coloredblocks.net>

=cut

sub file_mode_is($$;$)
	{
    if( _win32() )
		{
		$Test->skip( "file_mode_is doesn't work on Windows" );
		return;
		}
	
	my $filename = _normalize( shift );
	my $mode     = shift;

	my $name     = shift || sprintf("%s mode is %04o", $filename, $mode);

	my $ok = -e $filename && ((stat($filename))[2] & 07777) == $mode;

	if( $ok )
		{
		$Test->ok(1, $name);
		}
	else
		{
		$Test->diag(sprintf("File [%s] mode is not %04o", $filename, $mode) );
		$Test->ok(0, $name);
		}
	}

=item file_mode_isnt( FILENAME, MODE [, NAME ] )

Ok if the file exists and mode does not match, not ok
if the file does not exist or mode does match.

This test automatically skips if it thinks it is on a
Windows platform.

Contributed by Shawn Sorichetti <ssoriche@coloredblocks.net>

=cut

sub file_mode_isnt($$;$)
	{
    if( _win32() )
		{
		$Test->skip( "file_mode_isnt doesn't work on Windows" );
		return;
		}

	my $filename = _normalize( shift );
	my $mode     = shift;

	my $name     = shift || sprintf("%s mode is not %04o",$filename,$mode);

	my $ok = not (-e $filename && ((stat($filename))[2] & 07777) == $mode);

	if( $ok )
		{
		$Test->ok(1, $name);
		}
	else
		{
		$Test->diag(sprintf("File [%s] mode is %04o",$filename,$mode));
		$Test->ok(0, $name);
		}
	}

=back

=head1 TO DO

* check properties for other users (readable_by_root, for instance)

* check owner, group

* check times

* check number of links to file

* check path parts (directory, filename, extension)

=head1 SEE ALSO

L<Test::Builder>,
L<Test::More>

=head1 SOURCE AVAILABILITY

This source is part of a SourceForge project which always has the
latest sources in CVS, as well as all of the previous releases.

	http://sourceforge.net/projects/brian-d-foy/

If, for some reason, I disappear from the world, one of the other
members of the project can shepherd this module appropriately.

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT

Copyright 2002-2005, brian d foy, All Rights Reserved

You may use, modify, and distribute this under the same terms
as Perl itself.

=cut

"The quick brown fox jumped over the lazy dog";
