#!/usr/bin/env ruby

# frozen_string_literal: true
require "pathname"
require "../lib/arranger"

abort "usage: rearrange_files src dest" if ARGV.count != 2

src = Pathname(ARGV.shift)
dest = Pathname(ARGV.shift)


raise "source path not valid" unless src.directory?
raise "destination path not valid" unless dest.directory?

puts "src=|#{src.to_s}|; dest=|#{dest.to_s}|"
