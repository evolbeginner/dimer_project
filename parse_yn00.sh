#! /bin/bash

if [ ${#@} -eq 0 ]; then
	echo "parameter not given";
	exit;
fi

input=$1
[ ! -s $input ] && echo "input file cannot be opened $input" && exit;
if [ ! -z $2 ]; then
	output=$2
else
	output=$input.kaks
fi

[ ! -s $input ] && echo "input file cannot be opened $input" && exit;

perl -ne '@a=split;@b=sort split/\_/,@a[0]; print join ("\t",($b[0],$b[1],$a[3],$a[6],$a[9]))."\n" if($#a>=9 and defined $a[9])' $input > $output


