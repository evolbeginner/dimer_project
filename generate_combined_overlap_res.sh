#! /bin/bash

for i in `find ./ -type d -maxdepth 1 -mindepth 1`; do
	cat $i/inter_overlap.res  $i/non_inter_overlap.res  > $i/physical_overlap.res
	cat $i/inter_overlap.res2 $i/non_inter_overlap.res2 > $i/genetic_overlap.res
done

