#! /usr/bin/perl

use 5.010;
use Getopt::Long;


####################################################################################
my ($switch_PRINT_TAB_KA,$inter_file,@symbol_files,$outfile_1,$outfile_2,$outfile_3,$outdir,
	$rbs_file,@dup_list_files,$inter_switch,@inter_file,$head,$is_visualize,
	$count_inter,%pair);
my ($switch_PRINT_TAB_KA) = &read_param();
my $home="/home/sswang";
$switch_PRINT_TAB_KA=1 if not $switch_PRINT_TAB_KA;


####################################################################################
my $inter_file1="$home/project/dimer/data/DRYGIN/sgadata_costanzo2009_rawdata_101120.txt" if not $inter_file1;
my $inter_file2="$home/project/dimer/data/DRYGIN/sgadata_costanzo2010_correlations.txt" if not $inter_file2;
my $rbs_file="$home/project/dimer/seq/seq_list/rbs.txt";
@inter_file=($inter_file1, $inter_file2);


####################################################################################
my $outfile_1="$outdir/genetic_interaction_PD";
my $outfile_2="$outdir/genetic_interaction_non_PD";
my $outfile_3="$outdir/genetic_interaction_inter";

if (not @symbol_files){
	@symbol_files=("$home/project/dimer/seq/seq_list/WGD_PD.list",
	              "$home/project/dimer/seq/seq_list/WGD_non_PD.list");
}
if (not @dup_list_files){
	# kaks info should be given
	@dup_list_files = ("$home/project/dimer/result/kaks/yeast_WGD.kaks",
			   "$home/project/dimer/result/kaks/yeast_Guan2_SSD.kaks",
			   "$home/project/dimer/result/kaks/yeast_SSD.kaks",
		  	  );
}

my $inter_switch = 'OFF';   ################## 这是十分重要的一行，起到调控匹配方式的作用, random nteractions will be reported


#########################################################################################
&get_ka(\@dup_list_files);
&extract_rbs();
&extract_symbol(@symbol_files);


foreach my $inter_file(@inter_file)
{
	my %total;
	$count_inter++;
	my @outfile = &outfile_name($outfile_1,$outfile_2,$outfile_3,$count_inter);
	&extract_genetic_inter($inter_file);
	&PRINT_PD_NONPD(@outfile);
}
&stat_test();


######################################################
#####		       FUNCTION			 #####
sub stat_test{
    my @types=qw(non_PD PD);
    my $prefix="$outdir/genetic_interaction_";
    foreach my $order (qw(1 2)){
        print "\n###################\n";
        print "***      " . $order . "      ***". "\n";
        my @input_files=();
        foreach my $type (@types){
            my $file_name = "$prefix$type.$order";
            push @input_files, $file_name;
	}
	print "ttest\n"; system "ttest.pl $input_files[0] $input_files[1]";
	print "wilcox_test\n"; system "wilcox_test.pl $input_files[0] $input_files[1]";
    }
}


sub get_ka
{
    my ($dup_list_files_aref)=@_;
    foreach my $dup_list_file (@{$dup_list_files_aref}){
        open(IN,$dup_list_file);
	while(<IN>)
	{
		chomp;
		my @a=split;
		&Shu_Xie(@a);
		do {$ka{$_} = $a[2];} foreach (@a[0,1]);
		$KA{join("|",sort @a[0,1])}=$a[2];
	}
	close IN;
    }
}


sub extract_rbs
{
	open(IN,$rbs_file) || die "rbs_file $rbs_file cannot be opened!";
	while(<IN>)
	{
		chomp;
		my @a=split;
		&Shu_Xie(@a);
		do {$rbs{$_} = 0} foreach (@a);
	}
	close IN;
}


sub extract_symbol
{
	my @file_name=@_;
	foreach my $file_name(@file_name)
	{
		$hash_name = $file_name!~/non/ ? 'PD' : 'non_PD';

		open(IN,'<',$file_name);
		while(<IN>)
		{
			chomp;
			my @a=split;
			&Shu_Xie(@a);
			#print $a[0]."\n" and next if exists 'rbs' -> {$a[0]};
			next if exists $rbs{$a[1]};

			my @b=sort ($a[0],$a[1]);
			my $pair=join("|",$b[0],$b[1]);
			$pair{$pair}=1;
			$hash_name -> {$pair} = 1; #
			#$hash_name -> {$a[0]} = $a[1];
			#$hash_name -> {$a[1]} = $a[0];
			$para{$a[0]} = $a[1];
			$para{$a[1]} = $a[0];
		}
		close IN;
	}
}


sub extract_genetic_inter
{
	my ($inter_file)=@_;
	if ($head){
	    open(IN,"head $inter_file -n $head |");
	}
	else{
	    open(IN,$inter_file);
	}
	while(my $line=<IN>)
	{
		chomp($line);
		my @a;
		@a=(split /\t/,$line)[0,2,4];
		next if $#a != 2;
		&Shu_Xie(@a[0,1]);
		#next if not exists $para{$a[0]};
		#do { next if $a[1] ne $para{$a[0]} } if $inter_switch eq 'OFF';
		do { next if not exists $pair{join("|",sort @a[0,1])}} if $inter_switch eq 'OFF';
		&genetic(@a);
		#print OUT2 $genetic_abs{$a[0]}{$para{$a[0]}}."\t";
	}
	close IN;
}


sub Shu_Xie
{
	do {$_=uc($_);} foreach (@_);
}


sub genetic
{
	my @a=@_;
	&inter(@a) if $inter_switch eq 'ON';
	&non_inter(\@a,'non-abs') if $inter_switch eq 'OFF';
	#$genetic{$a[0]} -> {$a[1]} = $a[2];
	#$genetic{$a[1]} -> {$a[0]} = $a[2];
}


sub genetic_abs
{
	my @a=@_;
	#print $a[2]."\n";
	&inter(@a) if $inter_switch eq 'ON';
	&non_inter(\@a,'abs') if $inter_switch eq 'OFF';
	#$genetic_abs{$a[0]} -> {$a[1]} = abs($a[2]);
	#$genetic_abs{$a[1]} -> {$a[0]} = abs($a[2]);
}


sub inter
{
	my @a=@_;
	print OUT3 $a[2]."\n"  if exists $pair{join("|",sort @a)};
}

sub non_inter
{
	my ($a,$b)=@_;
	my @a=@{$a};
	my $name;
	$name='genetic'.'_'.$b if $b eq 'abs';
	$name='genetic' if $b eq 'non-abs';

	if ($b eq 'abs'){
		${$name}{$a[0]}{$a[1]} = abs($a[2]); #*
		#print $genetic_abs{$a[0]}{$a[1]}."\n";
		#$name{$a[1]} -> {$a[0]} = abs($a[2]);
	}
	else {
		$genetic{join("|",@a[0,1])} = $a[2]; #*
		print $genetic{join("|",sort @a[0,1])} . "\n" if $is_visualize;
		#$genetic{$a[1]} -> {$a[0]} = $a[2];
	}
}


sub PRINT_PD_NONPD
{
my ($outfile_1,$outfile_2,$outfile_3) = @_;
exit if $_[0] eq 'ON';  ####### 终止，退出程序
open(OUT1,">$outfile_1");
open(OUT2,">$outfile_2");
open(OUT3,">$outfile_3");
foreach my $hash_name('PD','non_PD')
{
	my $out_name;
	$out_name='OUT1' if $hash_name eq 'PD';
	$out_name='OUT2' if $hash_name eq 'non_PD';
	foreach my $pair (keys %{$hash_name})
	{
		next if not exists $genetic{$pair};
		$total{$hash_name} += ($genetic{$pair}=~/\d/) ? $genetic{$pair} : 0;
		++$k if $genetic{$pair} =~ /\d/;
		&PRINT_TAB_KA($_,$out_name) if $switch_PRINT_TAB_KA == 1; #########
		print $out_name $genetic{$pair}."\n";
	}
	#eval {print $hash_name."\t"; print $total{$hash_name}/$k; print "\n";};
	$k=0;
	close $out_name;
}
}


sub PRINT_TAB_KA
{
	my ($symbol,$out_name) = @_;
	my ($no_of_space);
	given ($ka{$symbol})
	{
		$no_of_space = int($_/0.2);
		when ($_ < 0.2) {print $out_name "\t" x $no_of_space}
		when ($_ < 0.4) {print $out_name "\t" x $no_of_space}
		when ($_ < 0.6) {print $out_name "\t" x $no_of_space}
		default {print $out_name "\t" x 3}
	}
	my $ka=$ka{$symbol};
}


#################	toll	###################
sub read_param
{
	GetOptions(
		'outdir=s'	    =>  \$outdir,
		'no_TAB_KA!'        =>  \$switch_PRINT_TAB_KA,
		'CDS=s'             =>  \$CDS_file,
		'symbol_file=s'     =>  \@symbol_files,
		'dup_list_file=s'   =>  \$dup_list_file,
		'inter_file=s'      =>  \@inter_file,
		'force!'	    =>	\$is_force,
		'head=s'	    =>	\$head,
		'v!'		    =>	\$is_visualize,
	) || die "illegal params!";
	$switch_PRINT_TAB_KA='OFF' if defined $no_TAB_KAI;
	die "outdir not given" if not $outdir;
	if (-d $outdir){
	    if ($is_force){
		`rm -rf $outdir`;
		`mkdir -p $outdir`;
	    }
	}
	else{
	    `mkdir -p $outdir`;
	}
	return($switch_PRINT_TAB_KA);
}


sub outfile_name{
	my (@file_name) = @_[0..2];
	my $count=@_[3];
	foreach(@file_name){
		$_.=".$count";
	}
	return(@file_name);
}

