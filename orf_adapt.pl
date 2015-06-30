#! /usr/bin/perl

use 5.010;
use Bio::SeqIO;


my ($ref_seq);

foreach my $argv(@ARGV){
	my ($ref_seq,$basename);
	$ref_seq = &read_fasta($argv);
	$basename = `basename \"$argv\"`;
	chomp($basename);
	print $basename."\n";
	open (OUT,'>',$basename);
	select OUT;
	foreach (keys %$ref_seq){
		$ref_seq->{$_} =~ s/\*//g;
		print ">$_"."\n".$ref_seq->{$_}."\n";
	}
	select STDOUT;
}

###############################################################################
###############################################################################
sub read_fasta{
        my ($input_seq) = @_;
        my %seq;
	my $catchseq_seqio_obj;
	$catchseq_seqio_obj = Bio::SeqIO->new(-file=>$input_seq, -format=>'fasta');
        while(my $seq_obj=$catchseq_seqio_obj->next_seq()){
                my ($full_name);
		$full_name = $seq_obj->display_name;
		$seq{$full_name} = $seq_obj->seq;
	}
	return(\%seq);
}
