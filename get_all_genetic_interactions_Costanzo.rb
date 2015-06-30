#! /bin/env ruby

inter={'positive'=>Hash.new,'negative'=>Hash.new}

home="/home/sswang"
Costanzo_file="#{home}/project/dimer/data/DRYGIN/sgadata_costanzo2009_rawdata_101120.txt"

#########################################################################################
fh=File.open(Costanzo_file, 'r')
while(line=fh.gets) do
  gene1, gene2, e = line.split("\t").values_at(0,2,4)
  e=e.to_f
  pair=[gene1,gene2].sort.join("|")
  if e >= 0.08 then
    inter['positive'][pair]=e
  elsif e <= -0.08 then
    inter['negative'][pair]=e
  end
end
fh.close

inter.each_key do |key1|
  fh=File.open(key1+'_interactions.list','w')
  inter[key1].each_pair do |key2,value|
    fh.puts [key2,value].join("\t")
  end
  fh.close
end

