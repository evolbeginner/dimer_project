#! /bin/bash

[ ! $1 ] && echo "no input" && exit; 


#########################################################
in_file=$1;
prefix=$2
outname=${prefix}_`basename "$in_file"`;
outdir=${outname}_GOSem_result_3.2.102;

[ -e $outdir ] 	 && rm $outdir/*;
[ ! -e $outdir ] && mkdir $outdir;

for i in Lin Wang Resnik Jiang
do
	R_command_file=$outdir/${outname}.R.$i;
	GOSem_result_file=$outdir/${outname}.GOSem.$i;
	GOSem_num_only=$outdir/${outname}.num.$i;

	perl get_GOSem.pl $in_file $i > ${R_command_file};
	Rscript $R_command_file > $GOSem_result_file;
	data=`grep -oP "(?<=\[1\] )(\d\..+)" $GOSem_result_file`;
	echo -e "${data[@]}\n" > $GOSem_num_only;
done

