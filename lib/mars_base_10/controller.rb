# frozen_string_literal: true

require_relative 'ship'
require_relative 'stack'
require_relative 'subject'

module MarsBase10
  class Controller
    def start
      self.viewport.open
    end

    def stop
      self.viewport.close
    end
  end
end
