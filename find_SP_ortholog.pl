#! /usr/bin/perl

#################################################
use 5.010;
use strict;

my ($inparanoid_file, $FungalOrthologs_file, $list_dir, $SP_biogrid_file);
my (%orth_rela, %orth_rela_FungalOrthologs, %HD);
my ($inparanoid_score_cutoff);

$list_dir=$ARGV[0];

$SP_biogrid_file = "/home/sswang/project/dimer/data/interaction_data/bao_cun/BIOGRID-ORGANISM-Schizosaccharomyces_pombe-3.2.115.tab2.txt";
#used to be 102
#$PD_list_file = "/home/sswang/project/dimer/script/inter_results/result_inter_yeast_WGD.txt.seq_similarity.0.2_physical/non_inter_list";
$inparanoid_file = "/home/sswang/software/sequence_analysis/inparanoid_4.1/table.orf_trans_1_line.fasta-Schizosaccharomyces_pombe.ASM294v1.16.pep.all.fa";

$FungalOrthologs_file = "/home/sswang/project/dimer/data/SP_SC/Fungal_Orthologs";

$inparanoid_score_cutoff = 0;


#################################################
&find_HD($SP_biogrid_file);

&read_inparanoid($inparanoid_file);

&read_FungalOrthologs($FungalOrthologs_file);

@orth_rela{keys %orth_rela_FungalOrthologs}=values %orth_rela_FungalOrthologs;

my @list_files=("$list_dir/non_inter_list", "$list_dir/inter_list");
foreach (@list_files){
    &read_PD_info($_);
}


=cut
foreach (keys %orth_rela){
	print $_."\n";
}
=cut


#################################################
sub find_HD{
	my ($SP_biogrid_file) = @_;
	open (my $IN, '<' , "$SP_biogrid_file");
	while(my $line=<$IN>){
		chomp($line);
    		my @a = split /\t/, $line;
		my ($name1,$name2) = &biogrid(\@a);
		$HD{'SP'}{$name1}=1 if ($name1 eq $name2);
	}
}

sub biogrid{
	my ($ref1) = @_;
	my $quality_ctrl;
	my ($name1,$name2,$inter_way,$type,$throughput) = @$ref1[5,6,11,12,17];
	$quality_ctrl='NO' if $throughput eq 'Low Throughput';
	return($name1,$name2,$inter_way,$type,$quality_ctrl);
}


sub read_PD_info{
	my ($fit_k, $exists_ortholog_k);
	my ($PD_list_file) = @_;
	open (my $IN, '<', "$PD_list_file") || die "PD_list_file $PD_list_file cannot be opened";
	while(<$IN>){
		my ($IS_fit, $exists_ortholog);
		chomp;
		for my $symbol (split){
			$exists_ortholog++ if defined $orth_rela{$symbol};
			for my $ortholog (keys %{$orth_rela{$symbol}}){
				$ortholog =~ s/\.1\:pep//;
				$IS_fit++ if exists $HD{'SP'}{$ortholog};
			}
		}
		$fit_k++ if $IS_fit;
		$exists_ortholog_k++ if $exists_ortholog;
	}
	print $exists_ortholog_k."\n";
	print $fit_k."\n";
}


sub read_inparanoid{
	my ($inparanoid_file) = @_;
	open (my $IN, '<', "$inparanoid_file") || die "inparanoid_file cannot be opened";
	while(<$IN>){
		my %gene;
		my $line_k=0;
		chomp;
		next unless /^\d/;
		map {print "111111$_\t"; map {print $_."\n"} keys %{$gene{$_}}} keys %gene;
		my @line = split /\t/;

		foreach my $key1 ($line[2],$line[3]){
			$line_k++;
			my @a = split /\s+/, $key1;
			map {$gene{$line_k}{$a[$_]} = $a[$_+1]} grep {!($_%2)} 0...$#a;
		}
	
		#map {map {print $_."\n"} keys %{$gene{$_}}} keys %gene;
		
		for my $b1 (keys %{$gene{1}}){
			next if $gene{1}{$b1} <= $inparanoid_score_cutoff;
			for my $b2 (keys %{$gene{2}}){
				next if $gene{2}{$b2} <= $inparanoid_score_cutoff;
				$orth_rela{$b1}{$b2} = 1;
				$orth_rela{$b2}{$b1} = 1;
			}
		}
	}
}


sub read_FungalOrthologs
{
    my $file= shift;
    open(my $IN, '<', $FungalOrthologs_file) || die "FungalOrthologs file cannot be found!";
    while(<$IN>){
	chomp;
	my @lines = split;
	foreach (@lines[1..$#lines]){
	    next if $_ eq 'NONE';
	    $orth_rela_FungalOrthologs{$lines[0]}{$_}=1;
	}
    }
    close $IN; 
}


