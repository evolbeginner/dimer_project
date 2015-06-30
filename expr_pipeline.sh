#! /bin/bash

normalized_array=normalized_array.pl

while [ $# -gt 0 ]; do
	case $1 in
		-d|--dir)
			dir_level1=$2;	shift;
			;;
		--result_dir|output_dir)
			result_dir=$2;	shift;
			;;
	esac
	shift
done

[ ! -e $result_dir ] && mkdir $result_dir

################################################################
for dir_level2 in `ls $dir_level1`; do
	for i in inter_list non_inter_list; do
		perl $normalized_array $dir_level1/$dir_level2/$i
		mv $i."expr.res" $result_dir/${dir_level2}_$i."expr.res"
	done
done

