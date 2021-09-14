# frozen_string_literal: true
require 'mars_base_10/viewport'
require 'urbit/urbit'

module MarsBase10
  class Error < StandardError; end

  class CommCentral
    attr_accessor :ship, :viewport

    def initialize(config_filename:)
      @ship = Urbit.connect(config_file: config_filename)
      @viewport = MarsBase10::ViewPort.new on_ship: @ship
    end

    def activate
      self.viewport.open
    end

    def shutdown
      self.viewport.close
    end
  end
end
