# frozen_string_literal: true
require "pathname"

#file = "/Users/cwulfman/repos/github/pulibrary/g_arrange/arranged.lis"
#file = "/tmp/neh_geniza.lis"
#file = "geniza_neh.lis"
file = "geniza_mcgraw.lis"
base = Pathname("/tmp/add_to_figgy")

File.foreach(file) do |line|
  path = base + Pathname(line.rstrip())
  puts path.to_s
  path.dirname.mkpath
  path.write("foo")
end
