# -*- perl -*-

# t/02_import.t - check imports and parameter passing

use Test::More tests => 4;
use File::RegexMatch;

$regexmatch = File::RegexMatch->new( verbose => 1 );

ok  ( defined $regexmatch);
ok  ( $regexmatch->isa('File::RegexMatch') );
is  ( $regexmatch->{verbose}, 1 );
ok  ( $regexmatch->match(base_directory => ".", pattern => qr/^.*$/) );
