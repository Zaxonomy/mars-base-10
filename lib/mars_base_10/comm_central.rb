# frozen_string_literal: true
require 'urbit'

require_relative  'graph_rover'
require_relative  'group_room'
require_relative  'viewport'

module MarsBase10
  class Error < StandardError; end

  class CommCentral
    def initialize(config_filename:)
      @viewport = Viewport.new
      ship = Urbit.connect(config_file: config_filename)
      ship.login
      sleep 2  # This is temporary for now, we need a way to know that the subscription callbacks have finished.
      # @controller    = GraphRover.new ship_connection: Urbit.connect(config_file: config_filename),
      #                            viewport:        @viewport
      @controller    = GroupRoom.new ship_connection: ship, viewport: @viewport
    end

    def activate
      self.controller.start
    end

    def shutdown
      self.controller.stop
    end

    private

    def controller
      @controller
    end
  end
end
