#! /usr/bin/perl

use 5.010;
use Getopt::Long;
use File::Basename;

my (@seq_list_file);
#push @INC, 'pre_process';
##################################################
GetOptions(
'dup_list=s'			=>	\@dup_list_file,
'seq_similarity!'		=>	\$seq_similarity,
'seq_similarity_cutoff=s'	=>	\$seq_similarity_cutoff,
'seq_similarity_file=s'		=>	\$seq_similarity_file,
) || die "illegal param!\n";

*seq_similarity_pass = generate_seq_similarity_pass($seq_similarity_file, $seq_similarity_cutoff) if $seq_similarity_file;
foreach (@dup_list_file){
	my $basename=basename("$_");
	push @dup_list_file_base, $basename . "-seq_similarity-$seq_similarity_cutoff";
}
my $outfile = join (",", @dup_list_file_base);

do 'exclude_WGD_from_paralog.pl';
*pair = read_clude_file(\@dup_list_file) if @dup_list_file;

open (my $OUT, '>', "$outfile") || die "outfile cannot be opened!\n";
select $OUT;
foreach (keys %pair){
	my $pair;
	next if not exists $seq_similarity_pass{$_};
	($pair = $_) =~ s/\|/\t/;
	print $pair."\n";
}
close $OUT;

###################################################
sub generate_seq_similarity_pass{
	my (%seq_similarity_pass);
	my ($seq_similarity_file, $seq_similarity_cutoff) = @_;
	die "seq_similarity_cutoff $seq_similarity_cutoff has not be specified!\n" if not $seq_similarity_cutoff;
	open ($IN, '<', $seq_similarity_file) || die "seq_similarity_file $seq_similarity_file cannot be opened!\n";
	while(<$IN>){
		chomp;
		my ($gene1, $gene2, $seq_similarity) = split;
		if ($seq_similarity >= $seq_similarity_cutoff){
			my $pair = join ("|", sort ($gene1, $gene2));
			$seq_similarity_pass{$pair} = 1;
		}
	}
	close $IN;
	return (\%seq_similarity_pass);
}

