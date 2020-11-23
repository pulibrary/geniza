# frozen_string_literal: true
require "pathname"
require "pry"

class Arranger
    attr_accessor :src, :dest, :base, :shelfmark_kb, :pathname_kb
  def initialize(src:, dest:)
    @src = Pathname(src)
    @dest = Pathname(dest)
    @shelfmark_kb = {}
    @pathname_kb = {}
    @libraries = ["ENA", "NS", "MS"]
    @series = ["NS", "L"]
    @pattern_1 = /^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_0*(?<leaf>\d+)_[rv]\.tiff?$/
    @pattern_2 = /^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_ruler\.tiff?$/
    @pattern_3 = /^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_0*(?<leaf>\d+)\.tiff?$/
    @pattern_4 = /^(?<lib>ENA|NS|MS)_(?<series>[^_]+)_(?<id>[^_]+)_0*(?<leaf>\d+)_[rv]\.tiff?$/
    @pattern_5 = /^(?<lib>ENA|NS|MS)_(?<series>[^_]+)_(?<id>[^_]+)_ruler\.tiff?$/
    @pattern_6 = /^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_(?<sub>[AB])_0*(?<leaf>\d+)\.tiff?$/
    @pattern_7 = /^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_(?<sub>[AB])_ruler\.tiff?$/

    add_rule(/^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_0*(?<leaf>\d+)_[rv]\.tiff?$/,
                       ->(m) { "#{m[:lib]} #{m[:id]}.#{m[:leaf]}" },
                       ->(m) { File.join( m[:lib], m[:id], m[:leaf].rjust(3, "0")) })

    add_rule(/^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_ruler\.tiff?$/,
             ->(m) { "" },
             ->(m) { File.join(m[:lib], m[:id]) })

    add_rule(/^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_0*(?<leaf>\d+)\.tiff?$/,
             ->(m) { "#{m[:lib]} #{m[:id]}.#{m[:leaf]}" },
             ->(m) { File.join(m[:lib], m[:id], m[:leaf].rjust(3, "0")) })

    add_rule(/^(?<lib>ENA|NS|MS)_(?<series>[^_]+)_(?<id>[^_]+)_0*(?<leaf>\d+)_[rv]\.tiff?$/,
             ->(m) { "#{m[:lib]} #{m[:series]} #{m[:id]}.#{m[:leaf]}" },
             ->(m) { File.join( m[:lib], m[:series], m[:id], m[:leaf].rjust(3, "0")) })

    add_rule(/^(?<lib>ENA|NS|MS)_(?<series>[^_]+)_(?<id>[^_]+)_ruler\.tiff?$/,
             ->(m) { "" },
             ->(m) { File.join(m[:lib], m[:series], m[:id]) })

    add_rule(/^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_(?<sub>[AB])_0*(?<leaf>\d+)\.tiff?$/,
             ->(m) { "#{m[:lib]} #{m[:id]}.#{m[:sub]}.#{m[:leaf]}" },
             ->(m) { File.join(m[:lib], m[:id], m[:sub]) })

    add_rule(/^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_(?<sub>[AB])_ruler\.tiff?$/,
             ->(m) { "" },
             ->(m) { File.join(m[:lib], m[:id], m[:sub]) })
  end


  def add_rule(pattern, shelfmark_action, pathname_action)
    shelfmark_kb[pattern] = shelfmark_action
    pathname_kb[pattern] = pathname_action
  end

  def files
    @files ||= src.children
  end

  def shelfmark(path)
    result = ''
    source_string = path.basename.to_s
    shelfmark_kb.each do |pattern, action|
      if m = source_string.match(pattern)
        result = action.call(m)
        break
      end
    end
    result
  end

  def shelfmark_old(path)
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
    when @pattern_7
      ""
    else
      raise "bad source path for shelf mark: #{path}"
    end
  end

  def target_path(path)
    result = ''
    source_string = path.basename.to_s
    pathname_kb.each do |pattern, action|
      if m = source_string.match(pattern)
        result = action.call(m)
        break
      end
    end
    raise "bad source path: #{path}" unless result
    Pathname(File.join(dest, result, path.basename))
  end

  # library series id leaf part
  def target_path_old(path)
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
    when @pattern_7
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
