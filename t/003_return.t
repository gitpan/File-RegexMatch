# -*- perl -*-

# t/03_return.t - check return of match sub

use Test::More tests => 5;
use File::RegexMatch;

$regexmatch = File::RegexMatch->new( verbose => 1 );

ok  ( defined $regexmatch);
ok  ( $regexmatch->isa('File::RegexMatch') );
is  ( $regexmatch->{verbose}, 1 );
ok  ( @ret = $regexmatch->match(base_directory => ".", pattern => qr/^.*$/) );
ok  ( defined @ret );
