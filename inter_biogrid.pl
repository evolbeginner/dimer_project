#! /usr/bin/perl
use 5.010;
use Getopt::Long;
use File::Basename;

###########################################################################
my ($quality_filter_swi, $rbs_filter_swi);

GetOptions(
	'dup_list=s'		=>	\$duplicate_list,
	'result_dir=s'		=>	\$result_dir_corename,
	'ka_cutoff=s'		=>	\$ka_cutoff,
	'rbs_filter=s'		=>	\$rbs_filter_swi,
	'rbs_file=s'		=>	\$rbs_file,
	'yeast_info_file=s'	=>	\$yeast_info_file,
	'quality_filter=s'	=>	\$quality_filter_swi,
) || die "illegal param!\n";

@inter_data = ("/home/sswang/project/dimer/data/interaction_data/SC_3.2.102_complete",
		"/home/sswang/project/dimer/data/interaction_data/dip20130707.txt",
		"/home/sswang/project/dimer/data/interaction_data/2012-10-29-mint-Saccharomyces.txt",
		"/home/sswang/project/dimer/data/interaction_data/intact.txt");
#@inter_data = @inter_data[2];

#($core_dup_list = basename("$duplicate_list")) =~ s/(^[^\.]+).*/$1/;
 ($core_dup_list = basename("$duplicate_list"));
my $result_dir_corename = 'result_inter_' . $core_dup_list if not defined $result_dir_corename;

for ($i=0; $i<1; $i+=0.2){
	my $j=$i+0.2;
	push @ka_range, $i.'-'.$j
}

$rbs_filter_swi = 'ON' if $rbs_filter_swi !~ /^(off|0)$/i;
print "rbs_filter is\t" . $rbs_filter_swi."\n";
$rbs_file="/home/sswang/project/dimer/seq/seq_list/rbs.list" if not $rbs_file;
$yeast_info_file = "/home/sswang/project/dimer/data/yeast_info.txt" if not $yeast_info_file;
$quality_filter_swi=1 if not defined $quality_filter_swi;
print "quality_filter is\t".$quality_filter_swi."\n";

$inter_type = 'physical';
$inter_type2 = 'genetic';

#$filtered_way = 'Two-hybrid';

$new_inter_type=$inter_type;	$new_inter_type =~ s/ /\_/g;
$result_dir = $result_dir_corename . 
		do{defined $inter_type ? '_'.$new_inter_type : undef} .
		do{defined $filtered_way ? '_NO'.$filtered_way : undef} .
		do{$quality_filter_swi ? undef : '_NO-quality'} .
		do{$rbs_filter_swi eq "ON" ? undef : '_WITH-rbs'}
		;

$inter_list = "inter_list";
$non_inter_list = "non_inter_list";
$inter_overlap_file = "inter_overlap.res";
$non_inter_overlap_file = "non_inter_overlap.res";
$inter_overlap_file2 = "inter_overlap.res2";
$non_inter_overlap_file2 = "non_inter_overlap.res2";
$random_inter_file = "random_inter.res";
$random_inter_file2 = "random_inter.res2";
$random_inter_file_num_only = "random_inter_num_only.res";
$random_inter_file2_num_only = "random_inter_num_only.res2";
$ka_cutoff = 0.6 if not defined $ka_cutoff;
$ka_list = 'ka_'.$ka_cutoff.'_list';
$ka_overlap_file = "ka_overlap_res".'_'.$ka_cutoff;
$ka_overlap_file2 = "ka_overlap_res2".'_'.$ka_cutoff;
$ka_xiaoyu_1_overlap_file = "ka_xiaoyu_1_overlap_res";

my @file = (	$inter_list, $non_inter_list,
		$inter_overlap_file, $non_inter_overlap_file, $inter_overlap_file2, $non_inter_overlap_file2,
		$random_inter_file, $random_inter_file_num_only, $random_inter_file2, $random_inter_file2_num_only,
		$ka_list, $ka_overlap_file, $ka_overlap_file2, $ka_xiaoyu_1_overlap_file);

(    		$inter_list, $non_inter_list, 
                $inter_overlap_file, $non_inter_overlap_file, $inter_overlap_file2, $non_inter_overlap_file2, 
                $random_inter_file, $random_inter_file_num_only, $random_inter_file2, $random_inter_file2_num_only, 
                $ka_list, $ka_overlap_file, $ka_overlap_file2,
		$ka_xiaoyu_1_overlap_file)	=	&create_dir($result_dir, \@file);
#($inter_list,$non_inter_list,$inter_overlap_file,$non_inter_overlap_file,$inter_overlap_file2,$non_inter_overlap_file2,$random_inter_file,$random_inter_file_num_only,$ka_overlap_file,$ka_overlap_file2) = &create_dir($result_dir,\@file);

for my $i (qw(all_ka_level PD_ka_level nonPD_ka_level)){
	my $dir = "$result_dir/$i";
	system "mkdir \"$dir\"";
	${$i.'_dir'} = $dir;
}

open(	$inter_list_FH,			'>',	"$inter_list");
open(	$non_inter_list_FH,		'>',	"$non_inter_list");	
open(	$inter_overlap_file_FH,		'>',	"$inter_overlap_file");
open(	$non_inter_overlap_file_FH,	'>',	"$non_inter_overlap_file");
open(	$inter_overlap_file2_FH,	'>',	"$inter_overlap_file2");
open(	$non_inter_overlap_file2_FH,	'>',	"$non_inter_overlap_file2");
open(	$random_inter_file_FH,		'>',	"$random_inter_file");
open(	$random_inter_file_num_only_FH,	'>',	"$random_inter_file_num_only");
open(	$random_inter_file2_FH,		'>',	"$random_inter_file2");
open(	$random_inter_file2_num_only_FH,'>',	"$random_inter_file2_num_only");
open(	$ka_list_FH,			'>',	"$ka_list");
open(	$ka_overlap_file_FH,		'>',	"$ka_overlap_file");
open(	$ka_overlap_file2_FH,		'>',	"$ka_overlap_file2");
open(	$ka_xiaoyu_1_overlap_file_FH,	'>',	"$ka_xiaoyu_1_overlap_file");


###########################################################################
*rbs = &extract_rbs($rbs_file) if $rbs_filter_swi eq 'ON';
*swiss =&extract_refseq($yeast_info_file);

(*pair, *para, *ka, *ks) = &read_ka_file($duplicate_list);


############################################################################
foreach my $inter_data(@inter_data){
print $inter_data."\n";
open( IN, '<', "$inter_data" ) || die "inter_data $inter_data cannot be opened";
while (my $line=<IN>){
	my ($inter_way,@a);
	my ($name1,$name2,$inter_way,$type,$throughput);
	chomp($line);
    @a = split /\t/, $line;
	($name1,$name2,$type,$throughput,$quality_filter) = &score_based(\@a,'DIP') if $line =~ /^DIP/;
	($name1,$name2,$type,$throughput,$quality_filter) = &score_based(\@a,'mint') if $line =~ /^uniprotkb/;
	($name1,$name2,$type,$throughput,$quality_filter) = &score_based(\@a,'intact') if $line =~ /^uniprotkb/;
	($name1,$name2,$inter_way,$type,$quality_filter)  = &biogrid(\@a) if $line =~ /^\d/;
	
	next if not defined $name1 or not defined $name2;
	do {next if $quality_filter eq 'NO'} if $quality_filter_swi;
	next if exists $rbs{$name1} or exists $rbs{$name2};

	if ($type eq $inter_type){
		next if defined $filtered_way and $inter_way eq $filtered_way;
		$inter{ $name1 }{ $name2 } ++;
    		$inter{ $name2 }{ $name1 } ++;

	if (exists $para{$name1}{$name2} ) {
			$hash_para{ $name2 } ++;
			$hash_para{ $name1 } ++;
		}

		$self{ $name1 } = 1 if $name1 eq $name2;
    		next if not exists $para{$name1} or not exists $para{$name2};
		$inter_random{join ('_',sort ($name1,$name2))}++;
	}

	elsif ($type eq $inter_type2){
		$inter2{ $name1 }{ $name2 } ++;
    		$inter2{ $name2 }{ $name1 } ++;
	}
}
close IN;
}


foreach my $pair ( keys %pair ) {
	my ( $para,$overlap,$num_r,$num_para,$overlap,$overlap2,$overlap_switch,$overlap2_switch);
	my ($r, $para) = split /\|/, $pair;
	# next if not exists $hash_para{$r};
    next if exists $rbs{$r} or exists $rbs{$para};
	
	if (exists $hash_para{$r}){
		print $inter_list_FH "$r\t$para\n";
		&connectivity($r,$para,"$result_dir/connect_para");
	}
	else{
		print $non_inter_list_FH "$r\t$para\n";
		&connectivity($r,$para,"$result_dir/connect_non_para");
		if (defined $ka_cutoff and $ka{$r} < $ka_cutoff){
			print $ka_list_FH "$r\t$para\n";
		}
	}

	#($overlap_interact_ratio{$r}{$para},$num_r,$num_para) = &get_overlap($r,$para);
	($overlap_interact_ratio{$r}{$para},$num_r,$num_para) = &get_overlap($inter{$r},$inter{$para});
	$overlap = $overlap_interact_ratio{$r}{$para};

	($overlap2,$num2_r,$num2_para) = &get_overlap($inter2{$r},$inter2{$para});
	$overlap2_switch = 1 if ($num2_r!=0 and $num2_para!=0);
	
	next if ($num_r==0 or $num_para==0);

	&histogram($overlap, $ka{$r}, $all_ka_level_dir);
	&histogram($overlap, $ka{$r}, $PD_ka_level_dir) if exists $hash_para{$r};
	&histogram($overlap, $ka{$r}, $nonPD_ka_level_dir) if not exists $hash_para{$r};

	if (exists $hash_para{$r}){
		print $inter_overlap_file_FH "$overlap\t$ka{$r}\n";
		print $inter_overlap_file2_FH "$overlap2\n" if defined $overlap2;
	}
	else{
		print $non_inter_overlap_file_FH "$overlap\t$ka{$r}\n";
		print $non_inter_overlap_file2_FH "$overlap2\n" if defined $overlap2;
	}
	
	if (defined $ka_cutoff and $ka{$r} < $ka_cutoff and not exists $hash_para{$r}){
		print $ka_overlap_file_FH "$overlap\n";
		print $ka_overlap_file2_FH "$overlap2\n" if defined $overlap2;
	}
	if ($ka{$r}>0.2){
		print $ka_xiaoyu_1_overlap_file_FH "$overlap\n";
	}
}


foreach my $inter_pair (keys %inter_random){
	my ( $num_r1, $num_r2, $overlap, $overlap2 );
	#next if $inter_random{$inter_pair} < 2;
	my @inter_pair = split /\_/,$inter_pair;
	($overlap,$num_r1,$num_r2) = &get_overlap(@inter{@inter_pair});
	($overlap2,$num2_r1,$num2_r2) = &get_overlap(@inter2{@inter_pair});
	
	if (defined $overlap){
		print $random_inter_file_FH "$inter_pair\t$overlap\n";
		print $random_inter_file_num_only_FH "$overlap\n";
	}
	if (defined $overlap2){
		print $random_inter_file2_FH "$inter_pair\t$overlap2\n";
		print $random_inter_file2_num_only_FH "$overlap2\n";
		#system "echo -e \"$overlap2\" >> \"$random_inter_file2_num_only\"";
	}	
}


###################################################################################################
sub histogram{
	my ($overlap, $ka, $outdir) = @_;
	my ($feiwu, $biggest_num);
	( $feiwu, $biggest_num ) = split /\-/,$ka_range[-1];
	for (@ka_range){
		my ($lower, $upper) = split /\-/, $_;
		if ($ka > $lower and $ka <= $upper){
			open (my $OUT, '>>' , "$outdir/$_") or die "$outdir error";
			&PRINT_overlap($OUT, $overlap);
			last;
		}
		elsif ($ka > $biggest_num){
			open (my $OUT, '>>' , "$outdir/${upper}+") or die "$outdir error";
			&PRINT_overlap($OUT, $overlap);
			last;
		}
	}
	sub PRINT_overlap{
		my ($OUT, $overlap) = @_;
		print $OUT "$overlap\n";
		close $OUT;
	}
}

sub get_overlap{
	my ($ref1,$ref2)=@_;
	my ($num_r1,$num_r2,$overlap_interact_ratio);
	my $overlap=0;
	$num_r1	= keys %{$ref1};
        $num_r2 = keys %{$ref2};
	foreach ( keys %{$ref1} ) {
		$overlap++ if exists ${$ref2}{$_};
	}
	#$overlap_interact_ratio = $overlap / ( $num_r1 + $num_r2 - $overlap ) if $num_r1 != 0 and $num_r2 != 0;
	$overlap_interact_ratio = 2 * $overlap / ( $num_r1 + $num_r2 ) if $num_r1 + $num_r2 != 0;
	return ($overlap_interact_ratio,$num_r1,$num_r2);
}

sub create_dir{
	my ($result_dir,$ref_file) = @_;
	my @file=@$ref_file;
	defined $result_dir ? do {$result_dir=$result_dir} : do {print 5};
	print "result_dir is\t".$result_dir."\n";
		system "[ -e \"$result_dir\" ] && rm -rf \"$result_dir\"/*";
		system "[ ! -e \"$result_dir\" ] && mkdir \"$result_dir\"";
		foreach(@file)	{$_="$result_dir/$_"};
	return(@file);
}

sub biogrid{
	my ($ref1) = @_;
	my $quality_filter;
	my ($name1,$name2,$inter_way,$type,$throughput) = @$ref1[5,6,11,12,17];
	$quality_filter='NO' if $throughput eq 'Low Throughput';
	return($name1,$name2,$inter_way,$type,$quality_filter);
}

sub score_based{
	my ($ref1,$method)=@_;
	my @a=@$ref1;
	my ($swiss1,$swiss2,$name1,$name2,$name01,$name02,$core,$ORGN);
	my ($type,$quality_filter);
	($name01,$name02,$ORGN,$score) = @a[0,1,9,14];
	given ($method){
		when ($_ eq 'DIP')	{
			$quality_filter='NO' if $score !~ /core/;
		}
		when ($_ eq 'mint' or $_ eq 'intact')	{
			my ($score_new) = $score =~ /score\:(.+)/;
			$quality_filter='NO' if not defined $score_new or $score_new !~ /^[.0-9]+$/ or $score_new < 0.3;
		}
	}

	return if $ORGN !~ /Saccharomyces/;

	($swiss1) = $name01 =~ /uniprotkb:(.+)/;
	($swiss2) = $name02 =~ /uniprotkb:(.+)/;
	return if not defined $swiss1 or not defined $swiss2;

	$name1 = $swiss{$swiss1} if exists $swiss{$swiss1};
	$name2 = $swiss{$swiss2} if exists $swiss{$swiss2};
	$type = 'physical';
	return ($name1,$name2,$type,$quality_filter);
}

sub connectivity{
	my ($gene1, $gene2, $outfile) = @_;
	my ($sum, $OUT);
	$a=scalar keys %{$inter{$gene1}}; 
	$b=scalar keys %{$inter{$gene2}};
	$sum = $a+$b;
	if ($a>=40 and $b>=40)			{open ($OUT, '>>', $outfile.'_40+40+.list')}
	elsif ($sum>=80 and ($a<40 or $b<40))	{open ($OUT, '>>', $outfile.'_40+40-.list')}
	else					{open ($OUT, '>>', $outfile.'_40-40-.list')}
	print $OUT "$gene1\t$gene2\n";
	close $OUT;
}
############################################################
sub read_ka_file
{
my ($duplicate_list) = @_;
my (%pair, %para, %ka);
open(my $IN, '<', "$duplicate_list") || die "duplicate_list $duplicate_list cannot be opened!\n";
while (<$IN>) {
    	chomp;
    	my @line          = split;
	my $pair = join ("|", sort @line[0,1]);
	$pair{$pair} = 1;
	map {$para{$line[$_]}{$line[1-$_]}=1} 0..1;
	@ka{@line[0,1]} = ($line[2]) x 2;
	@ks{@line[0,1]} = ($line[3]) x 2;
}
return (\%pair, \%para, \%ka, \%ks);
}

sub extract_rbs
{
	my ($rbs_file)=@_;
	my %rbs;
	open(IN,'<',$rbs_file);
	while(<IN>){
		chomp;
		do {      $_=uc($_);	$rbs{$_} = 0    } foreach (split);
	}
	return(\%rbs);
	close IN;
}

sub extract_refseq
{
	my ($yeast_info_file)=@_;
	my $ref2;
	open(my $IN, '<', $yeast_info_file) || die "yeast_info_file $yeast_info_file cannot be opened!\n";
	while(<$IN>){
		chomp;
		my @line=split /\t/,$_;
		next if not defined $line[4] or $line[4] !~ /\w/;
		$ref2->{$line[4]}=$line[1];
	}
	return($ref2);
}

