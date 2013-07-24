# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 4;

BEGIN { 
    use_ok('File::RegexMatch'); 
    use_ok('File::RegexMatch::File');
}

isa_ok(File::RegexMatch->new(), 'File::RegexMatch');
isa_ok(File::RegexMatch::File->new(path => './001_load.t'), 'File::RegexMatch::File');
