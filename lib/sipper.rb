# frozen_string_literal: true
require "pathname"
require "csv"
# require "pry"

# Generate a CSV of metadata, given a path to Geniza images.
# For each tif, get the shelfmark and the dirname

class Sipper
    attr_accessor :src, :base, :shelfmark_kb, :pathname_kb
  def initialize(src:)
    @src = Pathname(src)
    @shelfmark_kb = {}
    @pathname_kb = {}

    add_rule(/^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_0*(?<leaf>\d+)_[rv]\.tiff?$/,
                       ->(m) { "#{m[:lib]} #{m[:id]}.#{m[:leaf]}" },
                       ->(m) { File.join( m[:lib], m[:id], m[:leaf].rjust(3, "0")) })

    # add_rule(/^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_ruler\.tiff?$/,
    #          ->(m) { "" },
    #          ->(m) { File.join(m[:lib], m[:id]) })

    add_rule(/^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_0*(?<leaf>\d+)\.tiff?$/,
             ->(m) { "#{m[:lib]} #{m[:id]}.#{m[:leaf]}" },
             ->(m) { File.join(m[:lib], m[:id], m[:leaf].rjust(3, "0")) })

    add_rule(/^(?<lib>ENA|NS|MS)_(?<series>[^_]+)_(?<id>[^_]+)_0*(?<leaf>\d+)_[rv]\.tiff?$/,
             ->(m) { "#{m[:lib]} #{m[:series]} #{m[:id]}.#{m[:leaf]}" },
             ->(m) { File.join( m[:lib], m[:series], m[:id], m[:leaf].rjust(3, "0")) })

    # add_rule(/^(?<lib>ENA|NS|MS)_(?<series>[^_]+)_(?<id>[^_]+)_ruler\.tiff?$/,
    #          ->(m) { "" },
    #          ->(m) { File.join(m[:lib], m[:series], m[:id]) })

    add_rule(/^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_(?<sub>[AB])_0*(?<leaf>\d+)\.tiff?$/,
             ->(m) { "#{m[:lib]} #{m[:id]}.#{m[:sub]}.#{m[:leaf]}" },
             ->(m) { File.join(m[:lib], m[:id], m[:sub]) })

    # add_rule(/^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_(?<sub>[AB])_ruler\.tiff?$/,
    #          ->(m) { "" },
    #          ->(m) { File.join(m[:lib], m[:id], m[:sub]) })
  end

  def add_rule(pattern, shelfmark_action, pathname_action)
    shelfmark_kb[pattern] = shelfmark_action
    pathname_kb[pattern] = pathname_action
  end

  def items
    @items ||= create_items
  end

  def create_items
    items = {}
    src.glob("**/*.tif*").each do |img_path|
      shelfmark = shelfmark(img_path)
      items[shelfmark(img_path)] = img_path.dirname unless shelfmark.empty?
    end
    items
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

  def to_csv(file)
    csv = CSV.new(file, headers: ['title', 'local_identifier', 'path'], write_headers: true)
    items.each do |k, v|
      csv << [k, k, v]
    end
    csv
  end
end

class NehSipper < Sipper
  def initialize(src:)
    @src = Pathname(src)
    @shelfmark_kb = {}
    @pathname_kb = {}
    add_rule(/^MS_L_273_(?<leaf>\d+)_[rv]\.tif$/,
             ->(m) { "MS L 273.#{m[:leaf].gsub(/^0*/,'')}" },
             ->(m) { File.join('MS', 'L', '273', m[:leaf].rjust(3, "0")) })

    add_rule(/^(?<lib>MS)_(?<id>[^_]+)_(?<leaf>\d+)[Ci]+_[rv]\.tif$/,
             ->(m) { "#{m[:lib]} #{m[:id]} wrapper" },
             ->(m) { File.join( m[:lib], m[:id], 'wrapper') })


    add_rule(/^(?<lib>MS)_(?<id>[^_]+)_(?<leaf>\d+)_[rv]\.tif$/,
             ->(m) { "#{m[:lib]} #{m[:id]}.#{m[:leaf].gsub(/^0*/,'')}" },
             ->(m) { File.join( m[:lib], m[:id], m[:leaf].rjust(3, "0")) })

    add_rule(/^ENA_NS_85_vol_3_part_2_(?<leaf>\d+)_[rv]\.tif$/,
             ->(m) { "ENA NS 85.#{m[:leaf].gsub(/^0*/,'')}" },
             ->(m) { File.join('ENA', 'NS', '85', m[:leaf].rjust(3, "0")) })

    add_rule(/^ENA_NS_85_vol_3_part_2_(?<leaf>\d+)\.(?<sub>\d+)_[rv]\.tif$/,
             ->(m) { "ENA NS 85.#{m[:leaf].gsub(/^0*/,'')}.#{m[:sub]}" },
             ->(m) { File.join('ENA', 'NS', '85', m[:leaf].rjust(3, "0"), m[:sub] ) })

    add_rule(/^(?<lib>ENA|NS|MS)_(?<series>[^_]+)_(?<id>[^_]+)(_vol_\d)?_(?<leaf>\d+)_[rv]\.tif$/,
             ->(m) { "#{m[:lib]} #{m[:series]} #{m[:id]}.#{m[:leaf].gsub(/^0*/,'')}" },
             ->(m) { File.join( m[:lib], m[:series], m[:id], m[:leaf].rjust(3, "0")) })

    add_rule(/^(?<lib>ENA|NS|MS)_(?<series>[^_]+)_(?<id>[^_]+)(_vol_\d)?_(?<leaf>[^.]+)\.(?<sub>\d+)_[rv]\.tif$/,
             ->(m) { "#{m[:lib]} #{m[:series]} #{m[:id]}.#{m[:leaf].gsub(/^0*/,'')}.#{m[:sub]}" },
             ->(m) { File.join( m[:lib], m[:series], m[:id], m[:leaf].rjust(3, "0"), m[:sub] ) })

    add_rule(/^(?<lib>ENA|NS|MS)_(?<series>[^_]+)_(?<id>[^_]+)(_vol_\d)?_(?<leaf>[^.]+)\.(?<sub1>\d+)\.(?<sub2>\d+)_[rv]\.tif$/,
             ->(m) { "#{m[:lib]} #{m[:series]} #{m[:id]}.#{m[:leaf].gsub(/^0*/,'')}.#{m[:sub1]}.#{m[:sub2]}" },
             ->(m) { File.join( m[:lib], m[:series], m[:id], m[:leaf].rjust(3, "0"), m[:sub1], m[:sub2] ) })
  end

end
