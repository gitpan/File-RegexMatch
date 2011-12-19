package File::RegexMatch;

use strict;
use warnings;
use Cwd;
use Carp;
use Tie::IxHash;

require Exporter;

our @ISA     = qw(Exporter);
our @EXPORT  = qw(new match);
our $VERSION = "0.02";

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
		expression     => undef,
	);
	
	while(my ($key, $value) = each %param)
	{
		$opts{$key} = $value if exists $opts{$key};
	}
	
	croak "Expression must be a Regexp reference"
		unless ref($opts{expression}) eq "Regexp";

	# Locate files which match the given regex and 
	# the directories which they're associated with
	my %associated_matches = &_populate_match_hash(
		$self,
		$opts{base_directory}, 
		$opts{expression}
	);

	die "No files found matching the given expression\n"
		unless %associated_matches;

	# Merge the hash so we can return an array
	my @absolute_matches = &_hash_to_array(
		%associated_matches
	);

	return @absolute_matches;
}

sub _hash_to_array
{
	my %associated_files = @_;
	my @absolute_files   = ();

	while(my ($key, $value) = each %associated_files)
	{
		foreach(@{$associated_files{$key}})
		{
			push(@absolute_files, "$key/$_");
		}
	}

	return @absolute_files;
}

sub _populate_match_hash
{
	my $self       = shift;
	my $directory  = shift;
	my $expression = shift;
	
	chdir($directory) or croak "Unable to chdir into $directory: $!\n";
	
	my @base_files  = glob("*");
	my %directories = ();
	my %match_hash  = ();
	my @match_array = ();
	
	tie(%directories, "Tie::IxHash");
	
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
			if(m/$expression/)
			{
				print "Associating file $_ to $directory\n" if $self->{verbose};
				push(@match_array, $_);
			}
		}
	}
	
	# If there are files which match the regex in the base directory
	# associate them
	$match_hash{$directory} = [@match_array] if @match_array;
	@match_array = ();
	
	while(my ($key, $value) = each %directories)
	{
		# Solves the problem of some keys having double slashes
		$key =~ s/\/{2,}/\//g;
		chdir($key);
		my @files = glob("*");
		
		foreach(@files)
		{
			if(-d)
			{
				print "Adding directory $_ to hash\n" if $self->{verbose};
				$directories{&cwd . "/" . $_} = undef;
			}
			else
			{
				if(m/$expression/)
				{
					print "Associating file $_ to $key\n" if $self->{verbose};
					push(@match_array, $_);
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
	chdir($directory);

	return %match_hash;
}

1; 

__END__

=head1 NAME

File::RegexMatch - Extension to help find files using regular expressions.

=head1 SYNOPSIS

	#!/usr/bin/env perl

	use strict;
	use warnings;
	use File::RegexMatch;

	my $regexmatch = File::RegexMatch->new(
                verbose => 1
	);
	my @ret = $regexmatch->match(
                base_directory => "/home/user/public_html",
                expression     => qr/\.pl$/
	);

	foreach(@ret) { ... }

=head1 DESCRIPTION

This module provides a subroutine to return the absolute path of each file
found matching a given regular expression.

=head1 METHODS

=head2 new

Creates a new File::RegexMatch object. An optional argument for 
verbose can be passed to it. The value should be a boolean.

	my $regexmatch = File::RegexMatch->new(
		verbose => 1,
	);

=head2 match

Returns an array of files that match a given regular expression.  
It requires two parameters, B<base_directory> and B<expression>. 
expression must be a Regexp reference.

	$regexmatch->match(
		base_directory => "/home/user/public_html",
		expression     => qr/\.pl$/,
	);

=head1 BUGS

Please report any bugs to frm-bugs[at]singletasker.co.uk

=head1 AUTHOR

Lloyd Griffiths lloydg[at]singletasker.co.uk

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut
