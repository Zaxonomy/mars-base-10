# frozen_string_literal: true
require 'urbit/urbit'

require_relative  'graph_rover'
require_relative  'viewport'

module MarsBase10
  class Error < StandardError; end

  class CommCentral
    def initialize(config_filename:)
      @viewport = Viewport.new
      @rover    = GraphRover.new ship_connection: Urbit.connect(config_file: config_filename),
                                 viewport:        @viewport
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
