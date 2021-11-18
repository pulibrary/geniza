# frozen_string_literal: true
require "pathname"
require "csv"
#require "pry"

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
    src.glob("**/*.tif*").each do |path|
      original = Pathname(path)
      target = target_path(original)
      puts "#{original.to_s} ====> #{target.to_s}"
    end
  end

  def rearrange!
    src.glob("**/*.tif*").each do |path|
      original = Pathname(path)
      target = target_path(path)
      target.dirname.mkpath
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

class McgrawArranger < Arranger
  def initialize(src:, dest:)
    @src = Pathname(src)
    @dest = Pathname(dest)
    @shelfmark_kb = {}
    @pathname_kb = {}

    # ENA_1056_001_r.jp2
    add_rule(/^ENA_(?<id>[^_]+)_(?<leaf>[^_]+)_[rv]\.jp2$/,
             ->(m) { "ENA #{m[:id]}.#{m[:leaf].gsub(/^0*/,'')}" },
             ->(m) { File.join( "ENA", m[:id], m[:leaf].rjust(3, "0")) })

    # ENA_1822A_001_r.jp2
    # ENA_1822A_001_r.jp2
    # ENA_1822A_083a_r.jp2
    # ENA_2084_001V_r.jp2
    # ENA_2556_002a_r.jp2
    # ENA_2644b_10_r.jp2
    # ENA_2727_011cde_r.jp2
    # ENA_2727_015ab_r.jp2
    # ruler.jp2
    # ENA_2890_010.1_r.jp2

    # ENA_4096_e1_r.jp2
    # ENA_4096e1_r.jp2

    # ENA_4101_043.jp2
    # ENA_4101_044.jp2

    # ENA_NS_10_15_r.jp2

    # ENA_NS_13_001-2.jp2
    # ENA_NS_13_001_r.jp2
    # ENA_NS_13_001_v.jp2

    # ENA_NS_29__7_r.jp2

    # ENA_NS_77_375v.jp2

    # ENA_NS_I_001_r.jp2

    # ENA_NS_I_089c_v.jp2

    # KE_001_r.jp2

    # Krengel_001a_r.jp2
    # Krengel_010_r.jp2

    # MS_10160_001_r.jp2
    # MS_10674__fol__5_r.jp2
    # MS_10809_r.jp2
    # MS_4607_071a_r.jp2

    # MS_4607a_rule.jp2
    # MS_4607_rule.jp2

    # MS_8229_001.jp2

    # MS_L143_001_r.jp2
    # MS_L515_055a_r.jp2

    # MS_L516_000A.jp2
    # MS_L516_000.jp2

    # MS_L590_Vol_1_001_r.jp2

    # MS_L590_Vol_3_037.jp2
    # MS_L590_Vol__3__fol__14_r.jp2
    # MS_L594__fol__38a_r.jp2

    # MS_L596_027_r-1.jp2
    # MS_L596_027_r.jp2

    # MS_L597__fol__13_r.jp2

    # MS_R1449_001_r.jp2
  end
end
