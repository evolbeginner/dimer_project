$infile_Hahn="./Hahn_suppl.txt";
$infile_gene="/home/sswang/project/dimer/seq/seq_list/WGD_PD.list";


open(IN,$infile_gene);
while(<IN>)
{
       chomp;
       my @a=split;
       'para' -> {$a[0]} = 0;
       'para' -> {$a[1]} = 0;
}
close IN;


open(IN,"$infile_Hahn");
while(<IN>)
{
       chomp;
       #next if not /^Y/;
       my @a=split;
	next if $a[9] ne 'CONVERTED';
       next if $a[10] eq 'YES' or $a[11] eq 'YES';
       print ++$k."\t".$a[12]."\n" if exists 'para'->{$a[0]};
}
close IN;









