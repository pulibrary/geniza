# frozen_string_literal: true
require "pathname"
require "csv"
require "pry"

class Arranger
    attr_accessor :src, :dest, :base, :shelfmark_kb, :pathname_kb
  def initialize(src:, dest:)
    @src = Pathname(src)
    @dest = Pathname(dest)
    @shelfmark_kb = {}
    @pathname_kb = {}

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

  def rearrange
    src.glob("**/*.tif*").collect do |path|
      target = target_path(path.basename.sub_ext(".tif"))
       raise "Bad source path #{path}" if target.empty?
       raise "target already exists #{path}" if target.exist?
       { old: path, new: target_path(target) }
    end
  end

  def rearrange!
    src.glob("**/*.tif*").each do |path|
      target = target_path(path.basename.sub_ext(".tif"))
       raise "Bad source path #{path}" if target.empty?
       raise "target already exists #{path}" if target.exist?
       puts target.to_s
      FileUtils.mkdir_p target.dirname
      path.rename(target)
    end
  end

  def to_csv(file)
    csv = CSV.new(file, headers: ['local_identifier', 'path'], write_headers: true)
    src.glob("**/*.tif*").each do |path|
      src = path.basename.sub_ext(".tif")
      csv << [shelfmark(src), target_path(src)]
    end
    csv
  end
end

class NehArranger < Arranger
  def initialize(src:, dest:)
        @src = Pathname(src)
    @dest = Pathname(dest)
    @shelfmark_kb = {}
    @pathname_kb = {}

    add_rule(/^MS_L_273_(?<leaf>\d+)_[rv]\.tif$/,
             ->(m) { "MS L 273.#{m[:leaf].gsub(/^0*/,'')}" },
             ->(m) { File.join('MS', 'L', '273', m[:leaf].rjust(3, "0")) })

    add_rule(/^(?<lib>MS)_(?<id>[^_]+)_(?<leaf>\d+)[Ci]_[rv]\.tif$/,
             ->(m) { "#{m[:lib]} #{m[:id]} wrapper" },
             ->(m) { File.join( m[:lib], m[:id], 'wrapper') })


    add_rule(/^(?<lib>MS)_(?<id>[^_]+)_(?<leaf>\d+)_[rv]\.tif$/,
             ->(m) { "#{m[:lib]} #{m[:series]} #{m[:id]}.#{m[:leaf].gsub(/^0*/,'')}" },
             ->(m) { File.join( m[:lib], m[:series], m[:id], m[:leaf].rjust(3, "0")) })

    add_rule(/^ENA_NS_85_vol_3_part_2_(?<leaf>\d+)_[rv]\.tif$/,
             ->(m) { "ENA NS 85.#{m[:leaf].gsub(/^0*/,'')}" },
             ->(m) { File.join('ENA', 'NS', '85', m[:leaf].rjust(3, "0")) })

    add_rule(/^ENA_NS_85_vol_3_part_2_(?<leaf>\d+)\.(?<sub>\d+)_[rv]\.tif$/,
             ->(m) { "ENA NS 85.#{m[:leaf].gsub(/^0*/,'')}.#{m[:sub]}" },
             ->(m) { File.join('ENA', 'NS', '85', m[:leaf].rjust(3, "0"), m[:sub] ) })

    add_rule(/^(?<lib>ENA|NS|MS)_(?<series>[^_]+)_(?<id>[^_]+)_vol_\d_(?<leaf>\d+)_[rv]\.tif$/,
             ->(m) { "#{m[:lib]} #{m[:series]} #{m[:id]}.#{m[:leaf].gsub(/^0*/,'')}" },
             ->(m) { File.join( m[:lib], m[:series], m[:id], m[:leaf].rjust(3, "0")) })

    add_rule(/^(?<lib>ENA|NS|MS)_(?<series>[^_]+)_(?<id>[^_]+)_vol_\d_(?<leaf>[^.]+)\.(?<sub>\d+)_[rv]\.tif$/,
             ->(m) { "#{m[:lib]} #{m[:series]} #{m[:id]}.#{m[:leaf].gsub(/^0*/,'')}.#{m[:sub]}" },
             ->(m) { File.join( m[:lib], m[:series], m[:id], m[:leaf].rjust(3, "0"), m[:sub] ) })

  end
end
