#!/usr/bin/env ruby

# frozen_string_literal: true
require "pathname"
require_relative "../lib/mark_matcher"
require "csv"
require 'fileutils'

file = "/Users/cwulfman/repos/github/pulibrary/geniza/Ben_JTS.csv"
source_dir = "/tmp/add_to_figgy"
target_dir = "/tmp/fluff"

marker = MarkMatcher.new(dest: "")

table = CSV.parse(File.read(file), headers: true)

base = Pathname.new "/tmp/add_to_figgy"
dest_base = Pathname.new "/tmp/fluff"
map = {}
table.each do |row|
  target =  marker.target_path(row['shelfmark'])
  if target.class == Pathname
    src_path = Pathname(File.join(base, row['filename']))
    dest_path = Pathname(File.join("/tmp/fluff", target.to_s, row['filename']))
    #puts "#{base + row['filename']} ----> #{dest_path}"
#    puts "#{src_path} ====>> #{dest_path}"
    if src_path.file?
      dest_path.dirname.mkpath
      src_path.rename(dest_path)
#      map[row['shelfmark']] = target.to_s
      map[target.to_s] = row['shelfmark']
#      puts "#{row['shelfmark']},#{target.to_s}"
    else
#      puts "no source file #{src_path} for |#{row['shelfmark']}|"
    end
    
  else
#    puts "ERROR: no path for #{row['shelfmark']}"
  end
end
puts "shelfmark,path"
map.each { |k, v| puts "#{k},#{v}" }
