#! /usr/bin/perl

defined $ARGV[1] ? do {$method = $ARGV[1]} : do {$method = "Resnik"};


open(IN,'<',$ARGV[0]);
while(<IN>){
	my @p;
	for(split){push @p,$_}; 
	if (defined $p[0] and $p[0] !~ /^\d/){
print << "HERE"
geneSim("$p[0]","$p[1]", ont = "MF", organism = "yeast", measure = "$method");
HERE
}
}
close IN;

BEGIN	{print "library(GOSemSim);\n"}

