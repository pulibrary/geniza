# frozen_string_literal: true

class Matcher
  attr_accessor :kb

  def initialize
    @kb = {}
  end


  def add_rule(pattern, shelfmark_action, pathname_action)
    shelfmark_kb[pattern] = shelfmark_action
    pathname_kb[pattern] = pathname_action
  end

  def process(string)
    result = ''
    @kb.each do |pattern, action|
      if m = string.match(pattern)
        result = action.call(m)
        break
      end
    end
    result
  end
end
