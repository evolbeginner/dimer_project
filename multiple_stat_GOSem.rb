#! /bin/env ruby

require 'getoptlong'
require 'set'

stat_GOSem_result=[Dir.getwd, "stat_GOSem_result.sh"].join("/")

dir=nil
outdir=nil
x_label=nil
y_label=nil
dirs=Hash.new()

####################################################
opts=GetoptLong.new(
  ['--dir',GetoptLong::REQUIRED_ARGUMENT],
  ['--outdir',GetoptLong::REQUIRED_ARGUMENT],
  ['-x',GetoptLong::REQUIRED_ARGUMENT],
  ['-y',GetoptLong::REQUIRED_ARGUMENT],
)

opts.each do |opt,value|
  case opt
    when '--dir'
      dir=value
    when '--outdir'
      outdir=value
    when '-x'
      x_label=value
    when '-y'
      y_label=value
  end
end

raise "dir is not given" if not dir
#raise "outdir is not given" if not outdir
#`mkdir -p #{outdir}` if not Dir.exists? outdir

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
    cmd="bash #{stat_GOSem_result} #{k_a[0]} #{k_a[1]}"
    system "#{cmd}"
    print k_a[0], "\t", k_a[1]; puts
    #cmd="R_plot.rb -i #{k_a[0]} -i #{k_a[1]} --out_prefix #{outdir}/#{i[0]} -x #{x_label} -y #{y_label}"
    #`#{cmd}`
  end
end

