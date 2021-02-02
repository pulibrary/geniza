#!/usr/bin/env ruby

# frozen_string_literal: true
require "pathname"
require "../lib/sipper"

abort "usage: make_sip src to_file" if ARGV.count != 2

src = Pathname(ARGV.shift)
out = Pathname(ARGV.shift)


raise "source path not valid" unless src.directory?

puts "src=|#{src.to_s}|; out=|#{out.to_s}|"
sipper = Sipper.new src: src
File.open(out, "w") { |f| sipper.to_csv(f) }
