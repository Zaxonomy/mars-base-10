# frozen_string_literal: true
require 'mars_base_10/viewport'
require 'urbit/urbit'

module MarsBase10
  class Error < StandardError; end

  class CommCentral
    def initialize(config_filename:)
      @viewport = MarsBase10::ViewPort.new ship: Urbit.connect(config_file: config_filename)
    end

    def activate
      self.viewport.open
    end

    def shutdown
      self.viewport.close
    end

    private

    def viewport
      @viewport
    end
  end
end
