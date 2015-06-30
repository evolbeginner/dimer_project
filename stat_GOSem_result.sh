#! /bin/bash


dir1=$1;
dir2=$2;

file1=`grep -Po '([^/]+)(?=_GOSem_result)' <<< $dir1`.num
file2=`grep -Po '([^/]+)(?=_GOSem_result)' <<< $dir2`.num

for i in Jiang Wang Lin Resnik;
do 
	wilcox_test.pl $dir1/$file1.$i $dir2/$file2.$i
	ttest.pl $dir1/$file1.$i $dir2/$file2.$i
	echo;
done





