# frozen_string_literal: true
require 'urbit'

require_relative  'controller/group_room'
require_relative  'controller/graph_rover'
require_relative  'controller/social_lounge'
require_relative  'viewport'

module MarsBase10
  class Error < StandardError; end

  class MissionControl
    def initialize(config_filename:)
      @viewport = Viewport.new
      @ship = Urbit.connect(config_file: config_filename)
      @ship.login
      sleep 2  # This is temporary for now, we need a way to know that the subscription callbacks have finished.
      @controller = GroupRoom.new manager: self, ship_connection: @ship, viewport: @viewport
    end

    def activate
      self.controller.start
    end

    def swap_controller
      if GroupRoom == self.controller.class
        @controller = GraphRover.new manager: self, ship_connection: self.ship, viewport: @viewport
      elsif GraphRover == self.controller.class
        @controller = SocialLounge.new manager: self, ship_connection: self.ship, viewport: @viewport
      else
        @controller = GroupRoom.new  manager: self, ship_connection: self.ship, viewport: @viewport
      end
    end

    def shutdown
      self.controller.stop
    end

    private

    def controller
      @controller
    end

    def ship
      @ship
    end
  end
end
