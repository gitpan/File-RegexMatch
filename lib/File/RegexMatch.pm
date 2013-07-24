package File::RegexMatch;

use strict;
use warnings;
use Cwd;
use Carp;
use File::Spec;
use Tie::IxHash;
use File::RegexMatch::File;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(new match);
our $VERSION = '0.1.1';

sub new {
    my ($class, %params) = @_;
    my $self = {
        verbose => 0
    };

    while (my ($key, $value) = each %params) {
        $self->{$key} = $value if exists $self->{$key};
    }

    return bless $self, $class;
}

sub match {
    my ($self, %params) = @_;
    my %opts = (
        base_directory => $ENV{HOME},
        regex_pattern  => qr/.*/,
        include_hidden => 0,
    );

    while (my ($key, $value) = each %params) {
        $opts{$key} = $value if exists $opts{$key};
    }

    my @matched = ();
    my %matched_refs = $self->__populate(
        $opts{base_directory}, $opts{regex_pattern}, $opts{include_hidden}
    );

    while (my ($key, $value) = each %matched_refs) {
        foreach (@{$value}) {
            push @matched, File::RegexMatch::File->new(
                path => File::Spec->catfile($key, $_)
            );
        }
    }

    return @matched;
}

sub __populate {
    my ($self, $directory, $pattern, $include_hidden) = @_;
    my (%directories, %matches, @matches, @base) = ();

    chdir $directory;

    if ($include_hidden) {
        @base = glob ".* *";
    } else {
        @base = glob "*";
    }

    # Tie the hash to keep it ordered
    tie %directories, "Tie::IxHash";

    # Collect files and directories from the base directory
    $self->__collect($pattern, \@base, \@matches, \%directories);
    $self->__feedback(scalar @matches) if $self->{verbose} and scalar @matches;

    # Assign the matching files to the hash if there are any
    $matches{cwd()} = [@matches] if @matches;

    # Unset the matches ready for the next directory
    @matches = ();

    while (my ($key, $value) = each %directories) {
        my @files = ();
        chdir $key;

        if ($include_hidden) {
            @files = glob ".* *";
        } else {
            @files = glob "*";
        }

        # Collect files and directories from the current directory
        $self->__collect($pattern, \@files, \@matches, \%directories);
        $self->__feedback(scalar @matches) if $self->{verbose} and scalar @matches;
        $matches{$key} = [@matches] if @matches;
        $directories{$key} = [@files] if @files;

        # Unset the arrays ready for the next iteration
        @files = ();
        @matches = ();
    }

    # Return to the initial directory
    chdir $directory;
    return %matches;
}

sub __collect {
    my ($self, $pattern, $items, $matches, $directories) = @_;

    foreach (@{$items}) {
        if (m/^(\.|\.\.)$/) {
            next;
        } elsif (-d) {
            # Add each directory to the hash
            $directories->{File::Spec->catfile(cwd(), $_)} = undef;
        } elsif (m/$pattern/) {
            # If the file matches the regex pattern push it onto the array
            push @{$matches}, $_;
        } else {
            next;
        }
    }
}

sub __feedback {
    my ($self, $count) = @_;
    print $count . ' matching files found in ' . File::Spec::->catdir(cwd()) . "\n";
}

1;

__END__

=head1 NAME

File::RegexMatch - Module to help locate files using regular expressions.

=head1 SYNOPSIS

    #!/usr/bin/env perl -w

    use strict;
    use File::RegexMatch;

    foreach (File::RegexMatch->new(verbose => 1)->match(
        base_directory => "/home/user/public_html",
        regex_pattern  => qr/\.pl$/,
        include_hidden => 0
    )) {
        print $_->path() . "\n";
    }

=head1 DESCRIPTION

This module provides the functionality to traverses a directory tree
and return an array of File::RegexMatch::File objects. Each file that
is returned has a filename that matches the regular expression that is
passed to the C<match> subroutine.

=head1 METHODS

=head3 new

Instantiates and returns a new File::RegexMatch object. An optional
argument for verbose can be passed to the constructor. Verbose property
value is 0 (false) by default.

=head3 match

This method takes up to three parameter, C< base_directory >, C< regex_pattern >
and C< include_hidden >.

The C< base_directory > parameter defines the directory which the method should
start traversing. An absolute or relative path can be used. The default value
for this is C< $ENV{HOME} > - the users home directory.

The C<regex_pattern> parameter is the regular expression that you wish to match
file names against. The default value of this parameter is C< qr/.*/ >.

The C<include_hidden> parameter should be set to true if the method should
include hidden files in its search. By default it is set to false.

=head1 SEE ALSO

File::RegexMatch::File

=head1 BUGS

Please report any bugs or feature requests to lloydg@cpan.org

=head1 AUTHOR

Lloyd Griffiths

=head1 COPYRIGHT

Copyright (c) 2011-2013 Lloyd Griffiths

This library is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut