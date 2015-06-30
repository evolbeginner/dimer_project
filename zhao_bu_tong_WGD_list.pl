#! /usr/bin/perl

use 5.010;

open(IN1,"../seq/seq_list/WGD_PD.list");
while(<IN1>){
	chomp;
	$hash1{(join '_',sort split)}=1;
	}

open(IN2,"result_inter_WGD_physical/inter_list");
while(<IN2>){
	chomp;
	$hash2{(join '_',sort split)}=1;
}

foreach(keys %hash1){
	print $_."\n" if not exists $hash2{$_};
}




