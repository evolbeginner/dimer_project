#! /bin/bash

dir_level1=$1

GOSem_pipeline="./GOSem_pipeline.sh"

for dir_level2 in `ls $dir_level1`; do
	for pair_list in non_inter_list inter_list; do
		pair_list="$dir_level1/$dir_level2/$pair_list"
		prefix=$dir_level2
		bash $GOSem_pipeline $pair_list $prefix
		echo $pair_list
	done
done

