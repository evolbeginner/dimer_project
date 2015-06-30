open(IN1,"./Go-div,backupµÈ Zhaolei Zhang.txt");
while(<IN1>)
{
        chomp;
        @a=split /\s+/,$_;
        $a[0] =~ s/\-/\_/;
        $a[1] =~ s/\-/\_/;
        $a[4] =~ s/\?//;
        $zhang{$a[0]}=$a[1];
        $zhang{$a[1]}=$a[0];
        foreach (@a[0,1])
        {
                $go_div{$_}=$a[4];
                $backup{$_}=$a[5];
        }
}
close IN1;

&lala();
&exclude_complex();

open(IN2,"../yeast_WGD.txt");
while(<IN2>)
{
        chomp;
        @a=split;
        $PD{$a[0]}=$a[1];
        $PD{$a[1]}=$a[2];
        next if not exists $go_div{$a[0]};
        #print $go_div{$a[0]}."\n";
}
close IN2;



foreach (keys %PD)
{
         #$para=$para{$_};
         $para=$PD{$_};
         next if not exists $para{$_};
         next if not exists $go_div{$_};
         next if exists $You_Le{$_};
         next if $para ne $zhang{$_};
         do {next if not exists $para_complex{$_};} if $exclude_complex == 1;
         print ++$k."\n" if $backup{$_} eq "YES";
         $count++;
         $You_Le{$para}=1;
}
print $k/$count;




sub lala
{
    open(IN3,"../selected_seq/WGD_complex_SGD_cyc2008.txt");
    while(<IN3>)
    {
           my @b=split;
           $b[0] =~ s/\-/\_/;
           $b[1] =~ s/\-/\_/;
           $para{$b[0]}=$b[1];
           $para{$b[1]}=$b[0];
    }

    close IN3;
}


sub exclude_complex
{
    $exclude_complex=1;
    open(IN4,"../selected_seq/WGD_complex_SGD_cyc2008.txt");
    while(<IN4>)
    {
           my @b=split;
           $b[0] =~ s/\-/\_/;
           $b[1] =~ s/\-/\_/;
           $para_complex{$b[0]}=0;
           $para_complex{$b[1]}=0;
    }
    close IN3;
}
