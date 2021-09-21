# frozen_string_literal: true
require 'mars_base_10/viewport'
require 'urbit/urbit'

module MarsBase10
  class Error < StandardError; end

  class CommCentral
    def initialize(config_filename:)
      @viewport = Viewport.new
      @rover    = GraphRover.new ship: Urbit.connect(config_file: config_filename),
                                             viewport: @viewport
    end

    def activate
      self.rover.start
    end

    def shutdown
      self.rover.stop
    end

    private

    def rover
      @rover
    end
  end
end
