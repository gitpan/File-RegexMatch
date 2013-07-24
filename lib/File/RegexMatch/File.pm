package File::RegexMatch::File;

use strict;
use warnings;
use Carp;
use File::stat;

sub new {
    my ($class, %params) = @_;
    my ($self) = {
        path => undef,
    };

    while (my ($key, $value) = each %params) {
        $self->{$key} = $value if exists $self->{$key};
    }

    $self->{path} ? $self->{stat} = stat($self->{path}) : croak $!;
    return bless $self, $class;
}

sub path {
    return shift->{path};
}

sub dev {
    return shift->{stat}->dev();
}

sub ino {
    return shift->{stat}->ino();
}

sub mode {
    return shift->{stat}->mode();
}

sub nlink {
    return shift->{stat}->nlink();
}

sub uid {
    return shift->{stat}->uid();
}

sub gid {
    return shift->{stat}->gid();
}

sub rdev {
    return shift->{stat}->rdev();
}

sub size {
    return shift->{stat}->size();
}

sub atime {
    return shift->{stat}->atime();
}

sub mtime {
    return shift->{stat}->mtime();
}

sub ctime {
    return shift->{stat}->ctime();
}

sub blksize {
    return shift->{stat}->blksize();
}

sub blocks {
    return shift->{stat}->blocks();
}

1;

__END__

=head1 NAME

File::RegexMatch::File - Object to represent a file.

=head1 SYNOPSIS

#!/usr/bin/env perl -w

use strict;
use File::RegexMatch::File;

File::RegexMatch::File->new(path => '/path/to/file');

=head1 DESCRIPTION

This module allows each file that has been located by File::RegexMatch
to be represented by an object. The object has methods for retrieving
information about the file using the File::stat module. There are
different levels of support for certain filesystems. See
L<stat|http://perldoc.perl.org/functions/stat.html> for further information.

=head1 METHODS

=head3 new

Constructor for the object. Takes one parameter, which is the path of
the file. The library will croak if stat cannot be called on the file
path.

=head3 path

Returns the absolute path of the file.

=head3 dev

Returns the device number of the filesystem.

=head3 ino

Returns the inode number.

=head3 mode

Returns the type and permissions of the file.

=head3 nlink

Returns the number of hard links to the file.

=head3 uid

Returns the numeric user ID of the file owner.

=head3 gid

Returns the numeric group ID of the file owner.

=head3 rdev

Returns the device identifer.

=head3 size

Returns the total size of the file in bytes.

=head3 atime

Returns the last access time in seconds since the epoch.

=head3 mtime

Returns the last modify time in seconds since the epoch.

=head3 ctime

Returns the incode change time in seconds since the epoch.

=head3 blksize

Returns the preferred I/O size in bytes for interacting with the file.

=head3 blocks

Returns the actual number of system-specific blocks allocated on the
disk.

=head1 SEE ALSO

File::stat

L<stat|http://perldoc.perl.org/functions/stat.html>


=head1 BUGS

Please report any bugs or feature requests to lloydg@cpan.org

=head1 AUTHOR

Lloyd Griffiths

=head1 COPYRIGHT

Copyright (c) 2013 Lloyd Griffiths

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut