use ExtUtils::MakeMaker;

WriteMakefile(
	NAME         => 'File::RegexMatch',
	VERSION_FROM => 'lib/File/RegexMatch.pm',
	AUTHOR       => 'Lloyd Griffiths (lloydg@singletasker.co.uk)',
	ABSTRACT     => 'Extension to match files using regular expressions',
	PREREQ_PM    => {
		'Test::Simple' => 0.44,
		'Cwd'          => 3.31,
		'Carp'         => 1.17,
		'Tie::IxHash'  => 1.12,
	},
);
