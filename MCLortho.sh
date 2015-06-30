#! /bin/bash

orthomcl_config="/home/sswang/software/sequence_analysis/orthomclSoftware-v2.0.4/doc/OrthoMCLEngine/Main/orthomcl.config.template"



examine(){
	if [ ! -e compliantFasta ]
	then
		echo "warning: compliantFasta does not exist";
		echo "Would you like to build one? [Y|N]";
		read response
		if [[ $response =~ Y|y ]]	
		then
			mkdir -p compliantFasta
		else
			exit;
		fi
	fi
}

read_para(){
while getopts "b:si:j:" arg #选项后面的冒号表示该选项需要参数
do
	case $arg in
	b)
		echo -e "blast_programme:\t$OPTARG" 
		blast='true';
		blast_programme=$OPTARG;
		;;
	i)
		echo -e "input:\t$OPTARG"
		input=$OPTARG
		;;
	s)
		silent='true'
		;;
	j)	
		jiancheng=$OPTARG;
		;;
	?)	
		echo "unkonw argument"
        	#exit 1
        	;;
        esac
done
}


blast(){
echo $*
local blast;
local blast=$1;
local blast_programme=$2;

if [ "$blast" == 'true' ]
then
	echo "formatdb";
	formatdb -i "compliantFasta/${jiancheng}".fasta -p T -l "compliantFasta/formatdb.log";
	echo -ne "BLASTing\t";
	rm ./error.log;
	blast_command="blastall -p $blast_programme -i "compliantFasta/${jiancheng}.fasta" -d "compliantFasta/${jiancheng}.fasta" -e 1e-10 -o all_VS_all.out.tab -a 2 -m8";
	echo $blast_command;
	$blast_command;
fi
}




read_para $*;

examine;

cp "$input" "compliantFasta/${jiancheng}.fasta"

mysql -uroot -e 'drop database orthomcl; create database orthomcl;';

#-------------------------------------------------------------------

orthomclInstallSchema $orthomcl_config install_schema.log;

orthomclAdjustFasta $jiancheng $input 1;

cp ${jiancheng}.fasta compliantFasta;

blast $blast $blast_programme;

content=`ls compliantFasta`;
if [ "$silent" = 'true' ]
then
	cd compliantFasta; ls | grep -vP "^${jiancheng}.fasta$" | xargs rm; cd ../;
else
	echo "Y/N";
	read input; 
	if  [[ $input =~ Y|y ]]
	then
		cd compliantFasta; ls | grep -vP "^${jiancheng}.fasta$" | xargs rm; cd ../;
	fi
fi

 
orthomclBlastParser all_VS_all.out.tab compliantFasta > similarSequences.txt

orthomclLoadBlast $orthomcl_config similarSequences.txt

if [ -e pairs ]; then rm pairs -rf; fi;

orthomclPairs $orthomcl_config orthomcl_pairs.log cleanup=no

orthomclDumpPairsFiles $orthomcl_config

mcl mclInput --abc -I 1.5 -o mclOutput

orthomclMclToGroups GF_ 1 < mclOutput > groups.txt

mkdir orthomcl_result;

mv install_schema.log similarSequences.txt orthomcl_pairs.log groups.txt mclInput mclOutput pairs all_VS_all.out.tab\
	orthomcl_result




