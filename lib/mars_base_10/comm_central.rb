# frozen_string_literal: true
require 'mars_base_10/viewport'

module MarsBase10
  class Error < StandardError; end

  class CommCentral
    attr_accessor :viewport

    def initialize
      @viewport = MarsBase10::ViewPort.new
    end

    def activate
      self.viewport.open
    end

    def shutdown
      self.viewport.close
    end
  end
end
