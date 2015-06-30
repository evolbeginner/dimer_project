#! /bin/bash

kaks_file_dir=~/project/dimer/result/kaks

######################################################
for dir in `find ./ -type d -maxdepth 1 -mindepth 1`; do
	cd $dir >/dev/null
	if ! grep "result_inter" <<< $dir; then
		continue
	fi

	if grep 'Guan2_SSD' <<< $dir; then
		ka_file=$kaks_file_dir/yeast_Guan2_SSD.kaks
	elif grep 'WGD' <<< $dir; then
		ka_file=$kaks_file_dir/yeast_WGD.kaks
	fi
	perl ~/project/dimer/script/ka_PD_VS_nonPD.pl -in1 inter_list -in2 non_inter_list -ka_file $ka_file --detail --outdir ka_result --force
	#output="ka_PD_VS_nonPD.pvalue"
	#perl ~/project/dimer/script/ka_PD_VS_nonPD.pl -in1 inter_list -in2 non_inter_list -ka_file $ka_file | tee $output
	cd - >/dev/null
done

