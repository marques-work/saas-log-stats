#!/usr/bin/env ruby

raise "Please specify a data file" unless ARGV.size > 0
file = ARGV[0]

jobs = {}

pad = {:name => 0, :time => 0, :db => 0, :cpu => 0, :freq => 0, :avg => 0}

File.open(file, "r") do |f|
  f.each_line do |k|
    data = k.split(" ")

    next if data[1].to_i < 1000 # ignore runs < 1 sec

    name = data.shift[/[a-z_]+/]
    jobs[name] ||= [0, 0, 0, 0, 0.0]

    jobs[name][0] += data[0].to_i # total time
    jobs[name][1] += data[1].to_i # db time
    jobs[name][2] += data[2].to_i # cpu time
    jobs[name][3] += 1 # count
    jobs[name][4] = (jobs[name][0].to_f / jobs[name][3].to_f).round(2) # avg per run

    pad[:name] = name.size unless pad[:name] >= name.size
    pad[:time] = jobs[name][0].to_s.size unless pad[:time] >= jobs[name][0].to_s.size
    pad[:db] = jobs[name][1].to_s.size unless pad[:db] >= jobs[name][1].to_s.size
    pad[:cpu] = jobs[name][2].to_s.size unless pad[:cpu] >= jobs[name][2].to_s.size
    pad[:freq] = jobs[name][3].to_s.size unless pad[:freq] >= jobs[name][3].to_s.size
    pad[:avg] = jobs[name][4].to_s.size unless pad[:avg] >= jobs[name][4].to_s.size
  end
end



sorted_by_total_time = jobs.to_a.sort_by {|e| -e[1][0]}

File.open("bg-results.log", "w") do |f|
  header = "#{"name".rjust(pad[:name])} #{"time".to_s.rjust(pad[:time])} #{"db".to_s.rjust(pad[:db])} #{"cpu".to_s.rjust(pad[:cpu])} #{"freq".to_s.rjust(pad[:freq])} #{"avg".to_s.rjust(pad[:avg])}"
  f.puts header
  f.puts "-" * header.size

  sorted_by_total_time.each do |pair|
    f.puts "#{pair[0].rjust(pad[:name])} #{pair[1][0].to_s.rjust(pad[:time])} #{pair[1][1].to_s.rjust(pad[:db])} #{pair[1][2].to_s.rjust(pad[:cpu])} #{pair[1][3].to_s.rjust(pad[:freq])} #{("%0.2f" % pair[1][4]).rjust(pad[:avg])}"
  end
end
