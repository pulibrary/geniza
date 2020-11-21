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
    @pattern_3 = /^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_0*(?<leaf>\d+)\.tiff?$/
    @pattern_4 = /^(?<lib>ENA|NS|MS)_(?<series>[^_]+)_(?<id>[^_]+)_0*(?<leaf>\d+)_[rv]\.tiff?$/
    @pattern_5 = /^(?<lib>ENA|NS|MS)_(?<series>[^_]+)_(?<id>[^_]+)_ruler\.tiff?$/
    @pattern_6 = /^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_(?<sub>[AB])_0*(?<leaf>\d+)\.tiff?$/
  end

  def files
    @files ||= src.children
  end

  def shelfmark(path)
    case path.basename.to_s
    when @pattern_1
      "#{$~[:lib]} #{$~[:id]}.#{$~[:leaf]}"
    when @pattern_2
      ""
    when @pattern_3
      "#{$~[:lib]} #{$~[:id]}.#{$~[:leaf]}"
    when @pattern_4
      "#{$~[:lib]} #{$~[:series]} #{$~[:id]}.#{$~[:leaf]}"
    when @pattern_5
      ""
    when @pattern_6
      "#{$~[:lib]} #{$~[:id]}.#{$~[:sub]}.#{$~[:leaf]}"
    else
      raise "bad source path for shelf mark: #{path}"
    end
  end

  # library series id leaf part
  def target_path(path)
    case path.basename.to_s
    when @pattern_1
      Pathname(File.join(dest, $~[:lib], $~[:id], $~[:leaf].rjust(3, "0"), path.basename))
    when @pattern_2
      Pathname(File.join(dest, $~[:lib], $~[:id], path.basename))
    when @pattern_3
      Pathname(File.join(dest, $~[:lib], $~[:id], $~[:leaf].rjust(3, "0"), path.basename))
    when @pattern_4
      Pathname(File.join(dest, $~[:lib], $~[:series], $~[:id], $~[:leaf].rjust(3, "0"), path.basename))
    when @pattern_5
      Pathname(File.join(dest, $~[:lib], $~[:series], $~[:id], path.basename))
    when @pattern_6
      Pathname(File.join(dest, $~[:lib], $~[:id], $~[:sub], path.basename))
    else
      raise "bad source path: #{path}"
    end
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
