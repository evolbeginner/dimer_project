
my @p;
for(split){push @p,$_}; 
if (defined $p[0] and $p[0] !~ /^\d/){
print << "HERE"
geneSim("$p[0]","$p[1]", ont = "MF", organism = "yeast", measure = "Resnik");
HERE
}


BEGIN	{print "library(GOSemSim);\n"}

