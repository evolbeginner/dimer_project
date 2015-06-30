#! /bin/env ruby

require 'getoptlong'
require 'set'

cwd=Dir.getwd()
get_shared_proportion_based_on_SGA=[cwd, "get_shared_proportion_based_on_SGA.rb"].join("/")
genetic_interaction=[cwd, "genetic_interaction.pl"].join("/")

dir=nil
outdir=nil
stat_results=nil
dirs=Hash.new()
outdir_genetic_inter=nil


####################################################
opts=GetoptLong.new(
  ['--dir',GetoptLong::REQUIRED_ARGUMENT],
  ['--outdir',GetoptLong::REQUIRED_ARGUMENT],
  ['--outfile',GetoptLong::REQUIRED_ARGUMENT],
  ['--outdir_genetic_inter',GetoptLong::REQUIRED_ARGUMENT],
)

opts.each do |opt,value|
  case opt
    when '--dir'
      dir=value
    when '--outdir'
      outdir=value
    when '--outfile'
      stat_results=value
    when '--outdir_genetic_inter'
      outdir_genetic_inter=value
  end
end

raise "dir is not given" if not dir
[outdir, outdir_genetic_inter].each do |i|
  puts i
  Dir.mkdir i if ! Dir.exists?(i)
end
File.delete(stat_results) if File.exists?(stat_results)

####################################################
Dir.foreach(dir) do |file_name|
  next if file_name =~ /^\./
  file_name =~ /(.+seq_similarity.+?)(non_)?inter_list/
  dirs[$1]=Hash.new if dirs[$1].nil?
  dirs[$1][file_name]=1
end

dirs=dirs.sort_by{|k,v| k}
dirs.each do |i|
  puts "**********************************"
  puts i[0]
  i[1].keys.to_set.classify do |j|
    j=~/(result_inter_.+)seq_similarity/
    $1
  end.each_value do |k|
    k_a=k.to_a
    k_a.map!{|i| [dir,i].join("/")}
    k_a.each do |i|
      basename_i=File.basename i
      outfiles=Array.new
      para_lists=Array.new
      outfile=nil
      %w[non_inter_list inter_list].each do |j|
        outfile="#{outdir}/#{basename_i}_#{j}"
        outfiles.push outfile
        para_lists.push "#{i}/#{j}"
        cmd="ruby #{get_shared_proportion_based_on_SGA} --para_list #{i}/#{j} --out_prefix #{outfile}"
        puts cmd
        `#{cmd}`
      end
      %w[posi nega].each do |type|
        arg=outfiles.join(" ")+'_'+type
        `echo #{arg} >> #{stat_results}`
        `ttest.pl #{arg} >> #{stat_results}`
        `wilcox_test.pl #{arg} >> #{stat_results}`
        `echo #{stat_results}`
      end
      if outdir_genetic_inter then
        cmd="perl #{genetic_interaction} --symbol_file #{para_lists[0]} --symbol_file #{para_lists[1]} --outdir #{outdir_genetic_inter}/#{basename_i}"
        `#{cmd}`
      end
    end
  end
end

