use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'File::RegexMatch',
    VERSION_FROM => 'lib/File/RegexMatch.pm',
    AUTHOR       => 'Lloyd Griffiths (lloydg@cpan.org)',
    ABSTRACT     => 'Module to help locate files using regular expressions.',
    LICENSE      => 'perl',
    META_MERGE   => {
        resources => {
            repository => 'https://github.com/LloydGriffiths/File-RegexMatch',
        },
    },
    PREREQ_PM    => {
        'Test::Simple'  => 0.44,
        'Cwd'           => 3.12,
        'Carp'          => 1.04,
        'File::Spec'    => 3.12,
        'Tie::IxHash'   => 1.23,
        'File::stat'    => 0,
    },
);