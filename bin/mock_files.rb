# frozen_string_literal: true
require "pathname"

file = "/Users/cwulfman/repos/github/pulibrary/g_arrange/arranged.lis"
base = Pathname("/tmp/arranged")

File.foreach(file) do |line|
  path = base + Pathname(line.rstrip())
  puts path.to_s
  path.dirname.mkpath
  path.write("foo")
end
