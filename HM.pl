#! /usr/bin/perl

use Statistics::Basic qw(:all);
use Shell;
use Getopt::Long;
use 5.010;

my ($paralog_list, $kaks_file) = &read_param();

@file=("/home/sswang/project/dimer/data/HM/promoter_HM.txt","/home/sswang/project/dimer/data/HM/ORF_HM.txt");
my $rbs_file="/home/sswang/project/dimer/seq/seq_list/rbs.txt";
my $paralog_list = "/home/sswang/project/dimer/seq/seq_list/WGD_PD.list" if not defined $paralog_list;
my $kaks_file = "/home/sswang/project/dimer/result/kaks/yeast_WGD.kaks" if not defined $kaks_file;

my $outdir="result_HM";
system "[ ! -e \"$outdir\" ] && mkdir -p \"$outdir\"";

my $outfile_corename = basename ($paralog_list);
chomp($outfile_corename);

print $outfile_corename."\n";

#&extract_rbs();

&extract_kaks($kaks_file);
&extract_paralog($paralog_list);

&read_file();
#$name2='ORF_HM';
my @name_set_key = keys %name_set;
while(  my $name2=pop @name_set_key){
	my $outfile="$outdir/$outfile_corename".'_'.$name2.'_HM.res';
	&output_HM($name2,$outfile);
}

###################################
###################################
sub extract_kaks
{
	my ($kaks_file) = @_;
	open(IN1, '<', "$kaks_file") or die "cannot open kaks file";
	while(<IN1>){
		chomp;
		my @a=split;
		do {   &Shu_Xie($_);$ka{$_}=$a[2];	} foreach (@a[0,1]);
	}
	close IN1;
}

sub Shu_Xie
{
    do {$_=uc($_);} foreach (@_);
}

sub extract_paralog
{
my ($paralog_list)=@_;
open(IN2,'<',"$paralog_list") || die "cannot open paralog list";
while(<IN2>){
	chomp;
	my @a=split;
	$pair{join ('!',sort @a)}=1;
}
}

sub extract_rbs
{
    open(IN,$rbs_file);
    while(<IN>)
    {
           chomp;
           my @a=split;
           &Shu_Xie(@a);
           do {      'rbs' -> {$_} = 0    } foreach (@a);
    }
    close IN;
}

sub read_file
{
foreach my $file(@file)
{
        open(IN, '<', "$file") or die "cannot open $file";
        $file =~ s/\.txt//;
        $name = `basename "$file"`;
	chomp($name);
        while(<IN>)
        {
                next if not $_ =~ /^\w\w\w\d/;
                @a=split /\t/,$_;
                $a[0] =~ s/\-/\_/;
                $a[0] =~ s/[ ]$//;

                @num=(1..$#a);
                foreach (@num)
                {
                        next if $a[$_] =~ /[A-Z]/i;
                        ${$name}{$a[0]}{$_}=$a[$_];
                        $name_set{$name}=1;
                }
        }
}
}

sub output_HM
{
my ($name2,$outfile) = @_;
open(OUT, '>', "$outfile");
foreach (keys %pair)
{
         my (@x,@y);
	 my @pair = split /\!/,$_;
	 my ($seq1,$seq2) = @pair;
         foreach my $a1(keys %{${$name2}{$seq2}})
         {
                  if (exists ${$name2}{$seq2}{$a1}){
                      next if ${$name2}{$seq2}{$a1} !~ /^-?[.\d]+$/;
                      push @x,${$name2}{$seq1}{$a1};
                      push @y,${$name2}{$seq2}{$a1};
                  }
         }
         ######################################
         next if $#x < 5;
	
	$r = correlation (\@x,\@y);
	next if exists $rbs{$r} or exists $rbs{$para};
	select OUT;         
	given ($ka{$seq1}){
		when ($_ <= 0.2) {print OUT "\t" x 0;}
		when ($_ <= 0.4) {print OUT "\t" x 1;}
		when ($_ <= 0.6) {print OUT "\t" x 2;}
		default {print "\t" x 3}
	}
	print $r."\n";
	#print $para."\t".$r."\n";
}
close OUT;
}


###############################################################################
###############################################################################
sub read_param
{
GetOptions(
	'para=s'	=> \$paralog_list,
	'kaks=s'	=> \$kaks_file,
);
print $paralog_list."\n";
return($paralog_list,$kaks_file);
}



