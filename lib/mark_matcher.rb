# frozen_string_literal: true
require "pathname"
require "csv"
# require "pry"

class MarkMatcher
  attr_accessor :kb, :dest

  def initialize(dest:)
    @dest = Pathname(dest)
    @kb = {}

    # ENA 2826
    add_rule(/^(?<lib>ENA|NS)\s+(?<id>\d+)$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0")) })

    # ENA 2056.1
    add_rule(/^(?<lib>ENA|NS)\s+(?<id>\d+)\.0*(?<leaf>\d+(-\d+)?)$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0"), m[:leaf].rjust(6, "0")) })


    # ENA 1822A.1
    add_rule(/^(?<lib>ENA|NS)\s+(?<id>\d+[A-Za-z])\.(?<leaf>\d+\w?)$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0"), m[:leaf].rjust(6, "0")) })

    # ENA 4096a
    add_rule(/^(?<lib>ENA)\s+(?<id>\d+[a-z]\d?)(uler.*)?$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0")) })
    
    # ENA 1235.17.sleeve2
    add_rule(/^(?<lib>ENA)\s+(?<id>\d+)\.0*(?<leaf>\d+)\.(?<rest>.*)$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0"), m[:leaf].rjust(6, "0"), m[:rest]) })
    
    # ENA 2727.18d
    add_rule(/^(?<lib>ENA)\s+(?<id>\d+)\.0*(?<leaf>\d+\w*)(uler.*)?$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0"), m[:leaf].rjust(6, "0")) })

    # ENA 4096.e1
    add_rule(/^(?<lib>ENA)\s+(?<id>\d+)\.0*(?<leaf>\w+\d*)(uler.*)?$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0"), m[:leaf].rjust(6, "0")) })



    add_rule(/^(?<lib>ENA|NS)\s+(?<id>\w?\d+)uler.*?$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0")) })

    add_rule(/^(?<lib>ENA)\s+(?<id>\d+)\.(?<sub>[A-Z])\.(?<leaf>\d+)(uler.*)?$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0"), m[:sub], m[:leaf].rjust(6, "0")) })

    add_rule(/^(?<lib>ENA)\s+(?<id>\d+)\.(?<sub>[A-Z])uler.*?$/,
             ->(m) { File.join(dest, m[:lib], m[:id], m[:sub]) })



    add_rule(/^(?<lib>ENA)\s+(?<sub>NS)\s+(?<id>I)(uler.*)?$/,
             ->(m) { File.join(dest, m[:lib], m[:sub], m[:id]) })

    add_rule(/^(?<lib>ENA)\s+(?<sub>NS)\s+(?<id>I)\.0*(?<leaf>\d+\w?)(uler.*)?$/,
             ->(m) { File.join(dest, m[:lib], m[:sub], m[:id], m[:leaf].rjust(6, "0")) })

    add_rule(/^(?<lib>ENA)\s+(?<sub>NS)\s+(?<id>I)\.0*(?<leaf>\d+\w?)(uler.*)?$/,
             ->(m) { File.join(dest, m[:lib], m[:sub], m[:id], m[:leaf].rjust(6, "0")) })

    add_rule(/^(?<lib>ENA)\s+(?<sub>NS)\s+(?<id>\d+)\.0*(?<leaf>\d+\w?)(uler.*)?$/,
             ->(m) { File.join(dest, m[:lib], m[:sub], m[:id].rjust(6, "0"), m[:leaf].rjust(6, "0")) })

    # ENA NS 13.1-2
    add_rule(/^(?<lib>ENA)\s+(?<sub>NS)\s+(?<id>\d+)\.\.?0*(?<leaf>\d+(-\d+)?)(uler.*)?$/,
             ->(m) { File.join(dest, m[:lib], m[:sub], m[:id].rjust(6, "0"), m[:leaf].rjust(6, "0")) })

    # ENA NS 60
    add_rule(/^(?<lib>ENA)\s+(?<sub>NS)\s+(?<id>\d+\w?)(uler.*)?$/,
             ->(m) { File.join(dest, m[:lib], m[:sub], m[:id].rjust(6, "0"),) })

    add_rule(/^(?<lib>Schechter|KE|Krengel)\.(?<id>\d+\w?)(uler.*)?$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0")) })

    add_rule(/^(?<lib>Schechter|KE|Krengel)uler\.(?<id>\d+\w?)(uler.*)?$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0")) })

    # MS.L501.19; MS.4607.6
    add_rule(/^(?<lib>MS)\.(?<id>[A-Z]?\d+\w?)\.0*(?<leaf>\d+\w?(\.\d+)?)(uler.*)?$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0"), m[:leaf].rjust(6, "0")) })

    # MS.L596uler.1
    add_rule(/^(?<lib>MS)\.(?<id>\w?\d+)uler.*?$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0")) })

    # MS.L590.Vol.1.1
    add_rule(/^(?<lib>MS)\.(?<id>\w?\d+)\.(?<vol>Vol\.\d)\.(?<leaf>\d+)(uler.*)?$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0"), m[:vol], m[:leaf].rjust(6, "0")) })

    # MS.10809
    add_rule(/^(?<lib>MS)\.(?<id>\d+\w?)(uler.*)?$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0")) })

    # MS.10674..fol..5
    add_rule(/^(?<lib>MS)\.(?<id>[A-Z]?\d+\w?)\.+fol\.+(?<fol>\d+\w*)$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0"), "fol" + m[:fol]) })

    # MS.L590.Vol..3..fol..14
    add_rule(/^(?<lib>MS)[_.](?<id>[A-Z]?\d+\w?)[_.]+Vol[_.]+(?<vol>\d+)[_.]+fol[_.]+(?<fol>\d+)$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0"), "Vol" + m[:vol],  "fol" + m[:fol]) })
    

  end


  def add_rule(pattern, pathname_action)
    kb[pattern] = pathname_action
  end


  def target_path(shelfmark)
    result = ''
    kb.each do |pattern, action|
      if m = shelfmark.match(pattern)
        result = Pathname.new action.call(m)
        break
      end
    end
    result
  end
end
