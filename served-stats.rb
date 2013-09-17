#!/usr/bin/env ruby

raise "Please specify a data file" unless ARGV.size > 0
file = ARGV[0]

require "uri"

req = {}

pad = {:uri => 0, :time => 0, :freq => 0, :avg => 0}

# this takes an explicit uri and tries to use pattern matching to make it into a generic uri
# e.g. /projects/foobar/cards/10 --> /projects/[:identifier]/cards/[:numeric]
# this allows us to make meaningful aggregations
def tokenize_uri(u)
  u.gsub!(/^\/projects\/$/, "/projects")
  u.gsub!(/\/(\d+)$/, "/[:numeric]")
  u.gsub!(/\/(\d+)\//, "/[:numeric]/")
  u.gsub!(/\/(\d+)\.xml$/, "/[:numeric].xml")
  u.gsub!(/\/confirm_delete\/([\w]+)$/, "/confirm_delete/[:identifier]")
  u.gsub!(/\/delete\/([\w]+)$/, "/delete/[:identifier]")
  u.gsub!(/^\/projects\/([^\/]+)\//, "/projects/[:identifier]/")
  u.gsub!(/^\/api\/v2\/projects\/([^\/]+)\//, "/api/v2/projects/[:identifier]/")
  u.gsub!(/^\/api\/v2\/projects\/([^\/]+)\.xml$/, "/api/v2/projects/[:identifier].xml")
  u.gsub!(/^\/programs\/([^\/]+)\//, "/programs/[:identifier]/")
  u.gsub!(/^\/programs\/([^\/]+)\/projects\/([^\/]+)/, "/programs/[:identifier]/projects/[:identifier]")
  u.gsub!(/^\/(projects|programs)\/(\w+)\/?$/, "/\\1/[:identifier]")
  u.gsub!(/\/wiki\/([^\/]+)/, "/wiki/[:identifier]")
  u.gsub!(/\/objectives\/([^\/]+)/, "/objectives/[:identifier]")
  u.gsub!(/\/templatize\/([^\/]+)$/, "/templatize/[:identifier]")
  u.gsub!(/\/feeds\/([^\/]+)\.atom$/, "/feeds/[:hash].atom")
  u
end

File.open(file, "r") do |f|
  f.each_line do |k|
    data = k.split(" ")

    time = data.shift
    uri = URI.parse(data.shift[1..-2].split("?").first).path
    uri = tokenize_uri(uri)

    req[uri] ||= [0, 0, 0.0]

    req[uri][0] += time.to_i # total time
    req[uri][1] += 1 # count
    req[uri][2] = (req[uri][0].to_f / req[uri][1].to_f).round(2) # avg per run

    pad[:uri] = uri.size unless pad[:uri] >= uri.size
    pad[:time] = req[uri][0].to_s.size unless pad[:time] >= req[uri][0].to_s.size
    pad[:freq] = req[uri][1].to_s.size unless pad[:freq] >= req[uri][1].to_s.size
    pad[:avg] = req[uri][2].to_s.size unless pad[:avg] >= req[uri][2].to_s.size
  end
end



sorted_by_total_time = req.to_a.sort_by {|e| -e[1][0]}

File.open("served-results.log", "w") do |f|
  header = "#{"uri".ljust(pad[:uri])} #{"time".to_s.rjust(pad[:time])} #{"freq".to_s.rjust(pad[:freq])} #{"avg".to_s.rjust(pad[:avg])}"
  f.puts header
  f.puts "-" * header.size

  sorted_by_total_time.each do |pair|
    f.puts "#{pair[0].ljust(pad[:uri])} #{pair[1][0].to_s.rjust(pad[:time])} #{pair[1][1].to_s.rjust(pad[:freq])} #{pair[1][2].to_s.rjust(pad[:avg])}"
  end
end
