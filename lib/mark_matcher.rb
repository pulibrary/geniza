# frozen_string_literal: true
require "pathname"
require "csv"
# require "pry"

class MarkMatcher
  attr_accessor :kb, :dest

  def initialize(dest:)
    @dest = Pathname(dest)
    @kb = {}

    add_rule(/^(?<lib>ENA|NS|MS)_(?<id>[^_]+)_0*(?<leaf>\d+)_[rv]\.tiff?$/,
             ->(m) { File.join(dest, m[:lib], m[:id], m[:leaf].rjust(3, "0")) })

  end


  def add_rule(pattern, pathname_action)
    kb[pattern] = pathname_action
  end


  def target_path(shelfmark)
    result = ''
    kb.each do |pattern, action|
      if m = shelfmark.match(pattern)
        result = action.call(m)
        break
      end
    end
    result
  end
end
