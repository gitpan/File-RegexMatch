File::RegexMatch
===========

Module to help find files using regular expressions.

This is an easy-to-use file searching module. It returns File::RegexMatch::File objects,
each representing a file thats filename matches a provided regular expression.

Further documentation can be found on the CPAN (http://search.cpan.org/~lloydg).

Installation:

    perl Makefile.PL
    make test install clean all

Prerequisites:

    Test::Simple  => 0.44
    Cwd           => 3.12
    Carp          => 1.04
    File::Spec    => 3.12
    Tie::IxHash   => 1.23
    File::stat    => 0
