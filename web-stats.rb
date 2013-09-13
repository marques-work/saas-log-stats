#!/usr/bin/env ruby

raise "Please specify a data file" unless ARGV.size > 0
file = ARGV[0]

actions = {}
File.open(file, "r") do |f|
  f.each_line do |k|
    controller_action = k.strip
    actions[controller_action] ||= 0
    actions[controller_action] += 1
  end
end

sorted_by_incidence = actions.to_a.sort_by {|e| -e.last}

pad_to = sorted_by_incidence.first[1].to_s.length
File.open("machine-readable-results.data", "w") do |f1|
  File.open("web-results.log", "w") do |f2|
    sorted_by_incidence.each do |pair|
      f1.puts "#{pair[1]} #{pair[0]}"
      f2.puts "#{pair[1].to_s.rjust(pad_to)} #{pair[0]}"
    end
  end
end
