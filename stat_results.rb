#! /bin/env ruby

require 'getoptlong'
require 'set'

dir=nil
outdir=nil
x_label=nil
y_label=nil
dirs=Hash.new()

####################################################
opts=GetoptLong.new(
  ['-x',GetoptLong::REQUIRED_ARGUMENT],
  ['-y',GetoptLong::REQUIRED_ARGUMENT],
  ['--dir',GetoptLong::REQUIRED_ARGUMENT],
  ['--outdir',GetoptLong::REQUIRED_ARGUMENT],
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
`mkdir -p #{outdir}` if outdir

####################################################
Dir.foreach(dir) do |file_name|
  next if file_name =~ /^\./
  file_name =~ /(.+seq_similarity.+?)(non_)?inter_list\.expr\.res/
  dirs[$1]=Hash.new if dirs[$1].nil?
  dirs[$1][file_name]=1
end

dirs=dirs.sort_by{|k,v| k}
dirs.each do |i|
  puts i[0]
  i[1].keys.to_set.classify do |j|
    j=~/(result_inter_.+)seq_similarity/
    $1
  end.each_value do |k|
    k_a=k.to_a
    k_a.map!{|i| [dir,i].join("/")}
    if outdir then
      x_arg=['-x', x_label].join(' ') if x_label
      y_arg=['-y', y_label].join(' ') if y_label
      cmd="R_plot.rb -i #{k_a[0]} -i #{k_a[1]} --out_prefix #{outdir}/#{i[0]} #{x_arg} #{y_arg}"
      `#{cmd}`
    end
    system "ttest.pl #{k_a[0]} #{k_a[1]}"
    system "wilcox_test.pl #{k_a[0]} #{k_a[1]}"
  end
  puts "**********************************"
end

