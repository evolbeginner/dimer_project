#! /usr/bin/perl

use 5.010;
use Statistics::Basic qw(:all);

my ($base,@name,%name);

$array_dir = "/home/sswang/project/dimer/data/array/";
$WGD_complex_info = "/home/sswang/project/PPI实验/selected_seq/complex/WGD_complex_cyc2008_SGD_MIPS550.txt";
$SSD_complex_info = "/home/sswang/project/PPI实验/selected_seq/complex/yeast_SSD_self_complex_cyc2008_SGD_MIPS550.txt";
$dup_list = defined $ARGV[0] ? $ARGV[0] : "/home/sswang/project/dimer/seq/seq_list/Guan_SSD_non_PD.list";
$rbs_file = "/home/sswang/project/dimer/seq/seq_list/rbs.txt";

&extract_rbs($rbs_file);
&extract_complex();
&extract_PD();
&extract_dup($dup_list);

($name_ref1,$name_ref2,$base) = &read_array_data($array_dir);
@name=@$name_ref1;
%name=%$name_ref2;

*para_list = &extract_dup($dup_list);

die "file dup_list has not been given!\n" if not $dup_list or ( ! -f $dup_list );
my $outfile = `basename \"$dup_list\"`;
chomp($outfile);
$outfile .= '.expr.res';

open(OUT, '>', "$outfile");
foreach (keys %para_list)
{
	my ($symbol,$total);
	my @pair = split /\!/,$_;
	my ($r,$para) = @pair;
	next if exists $rbs -> {$r};
	#next if not exists $complex -> {$4};
	#next if not exists 'PD' -> {$4};
	
	###############
	my (@x,@y,$t);
	###############
	$symbol=$r;

	foreach my $file_name(keys %file_name){
		foreach (1..$base){
			if (exists ${$symbol}{$file_name}{$_} and exists ${$para}{$file_name}{$_}){
				next if ${$symbol}{$file_name}{$_} =~ /[A-Z]/i;
				next if ${$para}{$file_name}{$_} =~ /[A-Z]/i;
				push @x,${$symbol}{$file_name}{$_};
				push @y,${$para}{$file_name}{$_};
				#print STDOUT $#x."\t".$#y."\n";
			}
         	}
         }
         print OUT correlation(\@x,\@y)."\n";
}
close OUT;


#############################################
#############################################
##########         FUNCTION        ##########
sub extract_rbs
{
my ($rbs_file) = @_;
open(IN,'<',$rbs_file) or die "cannot open rbs file\n";
while(<IN>){
	chomp;
	my @a=split;
	do {$_=uc($_); $rbs -> {$_} = 0} foreach (@a);
}
close IN;
}


sub extract_complex
{
    open(IN,"$WGD_complex_info") or die "cannot open WGD_complex_info";
    while(<IN>)
    {
           chomp;
           my @a=split;
           do {$_=uc($_); $complex -> {$_} = 0} foreach (@a);
    }
}


sub extract_PD
{
    open(IN,$dup_list);
    while(<IN>)
    {
           chomp;
           my @a=split;
           do {$_=uc($_); 'PD' -> {$_} = 0} foreach (@a);
    }
}

sub xixi
{
foreach (keys %para)
{
         next if exists $dudu{$_};
         my $para=$para{$_};
         my $total=0;
         $symbol=$_;
         $dudu{$para}=0;

         foreach (1..$base)
         {
                  if (exists ${$symbol}{$_} and exists ${$para}{$_})
                  {
                       next if ${$symbol}{$_} =~ /[A-Z]/i;
                       next if ${$para}{$_} =~ /[A-Z]/i;

                       $a1=${$symbol}{$_}-$mean[$_];
                       $a2=${$para}{$_}-$mean[$_];
                       $b=$a1-$a2;
                       $c=$b*$b;
                       $total+=$c;
                       ####################
                       ${$symbol}{$_} = $a1/$SD{$_};
                       ${$para}{$_}   = $a2/$SD{$_};
                  }
         }
         #print $total/($num_mean-1)."\n";
}
}

sub read_array_data{
my ($array_dir) = @_;
my (%name,@name,$base);
opendir(INDIR, $array_dir);
foreach (readdir INDIR)
{
        next if not /(^array.+)/;
        my $file_name=$1;
        'file_name'->{$file_name} = 1;

        open (IN,"$array_dir/$_");
	my @num;
        while (<IN>)
        {	
		my (@a,$name);
                next if not $_ =~ /^\w\w\w\d/;
                chomp;
                @a=split /\t/,$_;
                $name=$a[0];
                $name=uc($name);
                @num=(0..$#a-2);
                foreach (@num)
                {
                        next if $a[$_] =~ /[A-Z]/i;
                        next if $a[$_] !~ /\./;
                        my $new_num=$base+$_+1;
                        ${$name}{$file_name}{$new_num}=$a[$_];
                        push @name,$name if not exists $name{$name};
                        $name{$name}=1;
                }

        }
        $base+=$#num;
        #print $base."\n";
        close IN;
}
return(\@name,\%name,$base);
}

sub extract_dup{
	my ($dup_list) = @_;
	my (%para_list);
	open (IN,'<',$dup_list);
	while (<IN>){
		chomp;
		my ($pair);
        	my @a=split;
		$pair = join ('!',@a);
		$para_list{$pair}=1;
	}
	return(\%para_list);	
}


######################################################################
######################################################################
exit;
######################################################################
######################################################################


foreach my $num(1..$base)
{	
         my $total=0;
         my $k=0;
         my @SD;
         foreach my $name(@name)
         {
                 next if not exists ${$name}{$num};
                 $total=${$name}{$num};
                 push @SD,${$name}{$num};
                 $k[$num]++;
         }
         #print $total."\n";
         $mean[$num]=$total/$k[$num] if defined $k[$num];
	 print $mean[$num]."\n";
         $SD{$num} = stddev(@SD);
}


