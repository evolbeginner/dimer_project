#! /usr/bin/perl

use strict;
use 5.010;
use Getopt::Long;

my (@exclude_file, @include_file);

##############################################
GetOptions(
	'exclude_file=s'	=>	\@exclude_file,
	'include_file=s'	=>	\@include_file,
) || die "illegal param!\n";


my $exclude_href = &read_clude_file(\@exclude_file);
my $include_href = &read_clude_file(\@include_file);

&output_include($exclude_href, $include_href);

###################################################
sub output_include{
	my ($exclude_href, $include_href) = @_;
	foreach (keys %$include_href){
		print $_."\n" if not exists $exclude_href->{$_};
	}
}

sub read_clude_file
{
	my %clude;
	my ($cludefile_aref) = @_;
	foreach(@$cludefile_aref){
		open (my $IN, '<', "$_") || die "$_ cannot be opened!\n";
		while(<$IN>){
			my @line = split;
			my $a = join ("|", sort @line[0,1]);
			$clude{$a} = 1;
		}
		close $IN;
	}
	return (\%clude);
}

