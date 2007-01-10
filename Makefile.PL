# $Id: Makefile.PL,v 1.9 2007/01/10 04:47:35 comdog Exp $
use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.14";

WriteMakefile
	(
	'NAME'           => 'Test::File',
	'ABSTRACT'       => 'Check file attributes',
	'LICENSE'       => 'perl',
	'VERSION_FROM'   => 'lib/File.pm',

	'PREREQ_PM' => {
		'Test::More'            => '0.65',
		'Test::Builder::Tester' => '1.04',
		'Test::Builder'         => '0.33',
		},

	'PM'        => {
		'lib/File.pm'     => '$(INST_LIBDIR)/File.pm',
		},

	'MAN3PODS'     => {
		'lib/File.pm' => '$(INST_MAN3DIR)/Test::File.3',
		},

	clean  => { FILES    => q|Test-File-* test_files| },
	);
