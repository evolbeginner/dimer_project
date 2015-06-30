#! /bin/env ruby

require 'getoptlong'
infiles=Hash.new
para_list=nil
inter=Hash.new
pairs=Hash.new
out_prefix=nil

infiles['nega']="/home/sswang/project/dimer/data/DRYGIN/negative_interactions.list"
infiles['posi']="/home/sswang/project/dimer/data/DRYGIN/positive_interactions.list"

####################################################
def read_interaction_file(file)
  hash=Hash.new
  fh=File.open(file, 'r')
    while(line=fh.gets) do
    line.chomp!
    lines=line.split("\t")
    gene1,gene2 = lines[0].split("|")
    gene1=$1 if gene1=~/(.+)_/
    gene2=$1 if gene2=~/(.+)_/
    [gene1, gene2].each do |i|
      hash[i]=Hash.new if hash[gene1].nil?
    end
    hash[gene1][gene2]=1
  end
  return(hash)
end

def get_pairs(file)
  hash=Hash.new
  fh=File.open(file, 'r')
  while(line=fh.gets) do
    line.chomp!
    hash[line]=1
  end
  return hash
end

####################################################
opts=GetoptLong.new(
  ['--nega',GetoptLong::REQUIRED_ARGUMENT],
  ['--posi',GetoptLong::REQUIRED_ARGUMENT],
  ['--para_list',GetoptLong::REQUIRED_ARGUMENT],
  ['--out_prefix',GetoptLong::REQUIRED_ARGUMENT],
)

opts.each do |opt,value|
  case opt
    when '--nega'
      infiles['nega']=value
    when '--posi'
      infiles['posi']=value
    when '--para_list'
      para_list=value
    when '--out_prefix'
      out_prefix=value
  end
end

####################################################
pairs = get_pairs(para_list)

infiles.each_pair do |type, file|
  inter[type]=Hash.new
  inter[type]=read_interaction_file file
end

inter.each_key do |type|
  $stdout.reopen(out_prefix+'_'+type, 'w') if out_prefix
  pairs.each_key do |key|
    genes=Array.new
    genes=key.split("\t")
    if (! inter[type][genes[0]].nil?) and (! inter[type][genes[1]].nil?) then
      overlap_array = inter[type][genes[0]].keys & inter[type][genes[1]].keys
      overlap = overlap_array.size
      shared_proportion=2*overlap.to_f/(inter[type][genes[0]].keys.size+inter[type][genes[1]].keys.size)
      #print overlap, "\t", inter[type][genes[0]].keys.size+inter[type][genes[1]].keys.size
      next if shared_proportion == 0
      puts shared_proportion
    end
  end
end

