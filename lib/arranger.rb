# frozen_string_literal: true
require "pathname"


class Arranger
    attr_accessor :src, :dest, :base
  def initialize(src:, dest:)
    @src = Pathname(src)
    @dest = Pathname(dest)
    @libraries = ["ENA", "NS", "MS"]
    @series = ["NS", "L"]
    @pattern_1 = /^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_0*(?<leaf>\d+)_[rv]\.tiff?$/
    @pattern_2 = /^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_ruler\.tiff?$/

  end

  def files
    @files ||= src.children
  end

  def shelfmark(path)
    case path.basename.to_s
    when @pattern_1
      "#{$~[:lib]} #{$~[:id]}.#{$~[:leaf]}"
    when /bar/
      "stuff"
    else
      raise "bad path: #{path}"
    end
  end

  # library series id leaf part
  def target_path(path)
    parsed = case path.basename.to_s
             when @pattern_1
               a = File.join(dest, $~[:lib], $~[:id], $~[:leaf].rjust(3, "0"), path.basename)
               Pathname(a)
             when @pattern_2
               a = File.join(dest, $~[:lib], $~[:id], path.basename)
               Pathname(a)

             else
               {}
             end
    parsed
  end

  def rearrange_old(path)
    new_fname = path.basename.sub_ext(".tif")
    parts = new_fname.basename(".tif").to_s.split("_")
    kind = parts.pop
    raise "bad path: #{path}" unless ["r", "v", "ruler"].include? kind

    if kind == "ruler"
      subdir = Pathname(File.join(parts))
    else
      leaf_number = parts.pop.sub(/^0*/,"")
      subdir = Pathname(leaf_number)
    end
    subdir
  end

end
