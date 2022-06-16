# frozen_string_literal: true

require_relative 'ship'
require_relative 'stack'
require_relative 'subject'

module MarsBase10
  class Controller
    def action_bar
      self.viewport.action_bar
    end

    def action_bar=(an_action_bar)
      self.viewport.action_bar = an_action_bar
    end

    def start
      self.viewport.open
    end

    def stop
      self.viewport.close
    end
  end
end
