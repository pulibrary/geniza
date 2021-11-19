# frozen_string_literal: true
require "pathname"
require "csv"
# require "pry"

class MarkMatcher
  attr_accessor :kb, :dest

  def initialize(dest:)
    @dest = Pathname(dest)
    @kb = {}

    # ENA 2056.1
    add_rule(/^(?<lib>ENA|NS)\s+(?<id>\d+)\.0*(?<leaf>\d+)$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0"), m[:leaf].rjust(6, "0")) })

    # ENA 1822A.1
    add_rule(/^(?<lib>ENA|NS)\s+(?<id>\d+[A-Z])\.0*(?<leaf>\d+)$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0"), m[:leaf].rjust(6, "0")) })
    
    add_rule(/^(?<lib>ENA|NS)\s+(?<id>\d+)uler.*?$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0")) })

    add_rule(/^(?<lib>ENA)\s+(?<id>\d+)\.(?<sub>[A-Z])\.(?<leaf>\d+)$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0"), m[:sub], m[:leaf].rjust(6, "0")) })

    add_rule(/^(?<lib>ENA)\s+(?<id>\d+)\.(?<sub>[A-Z])uler.*?$/,
             ->(m) { File.join(dest, m[:lib], m[:id], m[:sub]) })



    add_rule(/^(?<lib>ENA)\s+(?<sub>NS)\s+(?<id>I)uler.*$/,
             ->(m) { File.join(dest, m[:lib], m[:sub], m[:id]) })

    add_rule(/^(?<lib>ENA)\s+(?<sub>NS)\s+(?<id>I)\.0*(?<leaf>\d+\w?)$/,
             ->(m) { File.join(dest, m[:lib], m[:sub], m[:id], m[:leaf].rjust(6, "0")) })

    add_rule(/^(?<lib>ENA)\s+(?<sub>NS)\s+(?<id>I)\.0*(?<leaf>\d+\w?)$/,
             ->(m) { File.join(dest, m[:lib], m[:sub], m[:id], m[:leaf].rjust(6, "0")) })

    add_rule(/^(?<lib>ENA)\s+(?<sub>NS)\s+(?<id>\d+)\.0*(?<leaf>\d+)$/,
             ->(m) { File.join(dest, m[:lib], m[:sub], m[:id].rjust(6, "0"), m[:leaf].rjust(6, "0")) })


    add_rule(/^(?<lib>Schechter|KE|Krengel)\.(?<id>\d+\w?)$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0")) })

    add_rule(/^(?<lib>Schechter|KE|Krengel)uler\.(?<id>\d+\w?)$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0")) })

    # MS.L501.19
    add_rule(/^(?<lib>MS)\.(?<id>[A-Z]\d+)\.0*(?<leaf>\d+\w?)$/,
             ->(m) { File.join(dest, m[:lib], m[:id].rjust(6, "0"), m[:leaf].rjust(6, "0")) })


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
