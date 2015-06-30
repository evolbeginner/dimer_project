#! /bin/bash

for i in ../inter_results/result_inter_*; do
	basename=`basename $i`;
	perl genetic_interaction.pl --symbol $i/inter_list --symbol $i/non_inter_list --outdir kaka/$basename --force;
done

