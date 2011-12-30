package File::RegexMatch;

use strict;
use warnings;
use Cwd;
use Carp;
use Tie::IxHash;

require Exporter;

our @ISA     = qw(Exporter);
our @EXPORT  = qw(new match);
our $VERSION = "0.03";

sub new 
{
	my $class = shift;
	my %param = @_;
	my $self  = {
		verbose => 0,
	};

	while(my ($key, $value) = each %param) 
	{
		$self->{$key} = $value if exists $self->{$key};
	}

	return bless $self, $class;
}

sub match
{
	my $self  = shift;
	my %param = @_;
	my %opts  = (
		base_directory => undef,
		pattern        => undef,
		include_hidden => 0,
	);
	
	while(my ($key, $value) = each %param)
	{
		$opts{$key} = $value if exists $opts{$key};
	}
	
	croak "No value given for base_directory."
		unless $opts{base_directory};

	croak "Pattern must be a Regexp reference"
		unless ref $opts{pattern} eq "Regexp";

	# Locate files which match the given regex and 
	# the directories which they're associated with
	my %associated_matches = &_populate_match_hash(
		$self,
		$opts{base_directory}, 
		$opts{pattern},
		$opts{include_hidden},
	);

	die "No files found matching the given pattern\n"
		unless %associated_matches;

	# Merge the hash so we can return an array
	my @absolute_matches = &_merge_hash(
		%associated_matches
	);

	return @absolute_matches;
}

sub _merge_hash
{
	my %associated_files = @_;
	my @absolute_files   = ();

	while(my ($key, $value) = each %associated_files)
	{
		foreach(@{$associated_files{$key}})
		{
			push @absolute_files, "$key/$_";
		}
	}

	return @absolute_files;
}

sub _populate_match_hash
{
	my $self       = shift;
	my $directory  = shift;
	my $pattern    = shift;
	my $hidden     = shift;	

	chdir $directory or croak "Unable to chdir into $directory: $!\n";
	
	my %directories = ();
	my %match_hash  = ();
	my @match_array = ();
	my @base_files  = ();

	if($hidden)
	{
		@base_files = glob ".* *";
	}
	else
	{
		@base_files = glob "*";
	}
	
	tie %directories, "Tie::IxHash";
	
	foreach(@base_files)
	{
		# We want to skip current and parent directory
		next if m/^(\.|\.\.)$/;
		
		if(-d)
		{
			print "Adding directory $_ to hash\n" if $self->{verbose};
			$directories{&cwd . "/" . $_} = undef;
		}
		else
		{
			if(m/$pattern/)
			{
				print "Associating file $_ to $directory\n" if $self->{verbose};
				push @match_array, $_;
			}
		}
	}
	
	# If there are files which match the regex in the base directory
	# associate them
	$match_hash{&cwd} = [@match_array] if @match_array;
	@match_array = ();
	
	while(my ($key, $value) = each %directories)
	{
		# Solves the problem of some keys having double slashes
		$key =~ s/\/{2,}/\//g;

		if($self->{verbose})
		{
			chdir $key or warn "Cannot chdir into $key: $!\n";
		}
		else
		{
			chdir $key;
		}

		my @files = ();

		if($hidden)
		{
			@files = glob ".* *";
		}
		else
		{
			@files = glob "*";
		}

		foreach(@files)
		{
			next if m/^(\.|\.\.)$/;

			if(-d)
			{
				print "Adding directory $_ to hash\n" if $self->{verbose};
				$directories{&cwd . "/" . $_} = undef;
			}
			else
			{
				if(m/$pattern/)
				{
					print "Associating file $_ to $key\n" if $self->{verbose};
					push @match_array, $_;
				}
			}
		}
		
		# Associate matching files with corresponding directory
		$match_hash{$key}  = [@match_array] if @match_array;
		# Associate all files with corresponding directory
		$directories{$key} = [@files] if @files;
		# Clear arrays for the next iteration
		@files       = ();
		@match_array = ();
	}

	# Return to the base directory when we finish
	chdir $directory;

	return %match_hash;
}

1; 

__END__

=head1 NAME

File::RegexMatch - Extension to help find files using regular expressions

=head1 SYNOPSIS

	#!/usr/bin/env perl -w

	use strict;
	use File::RegexMatch;

	my $regexmatch = File::RegexMatch->new(
		verbose => 1,
	);

	my @ret = $regexmatch->match(
		base_directory => "/home/user/public_html",
		pattern        => qr/\.pl$/,
		include_hidden => 0,                
	);

	foreach(@ret) { ... }

=head1 DESCRIPTION

This module provides a subroutine which traverses a directory tree
and returns an array of files which match a given regular expression. 
The absolute path for each matching file is returned.

=head1 METHODS

=head3 new

C<< $regexmatch = File::RegexMatch->new() >>

Creates a new File::RegexMatch object. An optional argument for verbose can be passed to it, default value is 0.

=head3 match

C<< $regexmatch->match() >>

Takes three parameters, C<base_directory>, C<expression> and C<include_hidden>. 

The C<base_directory> parameter defines the directory which is to be traversed. 
Either a relative or absolute path can be given. 

The C<pattern> parameter is the regular expression that you want to match files against. 
This must be a regexp referece or the subroutine will complain.


The C<include_hidden> parameter lets the subroutine know if it should include hidden files (files beginning with a .) 
in the search. The value given should be a boolean, but the subroutine won't complain if it's not.

=head1 BUGS

Please report any bugs to frm-bugs[at]singletasker.co.uk

=head1 AUTHOR

Lloyd Griffiths lloydg[at]singletasker.co.uk

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut
