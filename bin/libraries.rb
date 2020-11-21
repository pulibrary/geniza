# frozen_string_literal: true
require "pathname"

file = "/Users/cwulfman/repos/github/pulibrary/geniza/qc/converted_tiff.lis"

# libraries = Set.new()

libraries = Hash.new(0)

File.foreach(file) do |line|
  path = Pathname(line)
  #  libraries.add path.basename.to_s.split("_").first
  lib = path.basename.to_s.split("_")[1]
  libraries[lib] += 1
end
puts libraries.keys
