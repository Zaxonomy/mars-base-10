# frozen_string_literal: true
require 'urbit'

require_relative  'controller/group_room'
require_relative  'controller/graph_rover'
require_relative  'controller/social_lounge'
require_relative  'viewport'

module MarsBase10
  class Error < StandardError; end

  class MissionControl
    attr_accessor :controller
    attr_reader   :ship

    def initialize(config_filename:)
      @ship = Urbit.connect(config_file: config_filename)
      @ship.login
      sleep 2  # This is temporary for now, we need a way to know that the subscription callbacks have finished.
      @viewport = Viewport.new
      @controller = GroupRoom.new manager: self, ship_connection: @ship, viewport: @viewport
    end

    def activate
      self.controller.start
    end

    def assign(controller_class:)
      @viewport.dispose_panes
      self.controller = controller_class.send(:new, {manager: self, ship_connection: self.ship, viewport: @viewport})
    end

    def shutdown
      self.controller.stop
    end

    def swap_controller
      if GroupRoom == self.controller.class
        cls = GraphRover
      elsif GraphRover == self.controller.class
        cls = SocialLounge
      else
        cls = GroupRoom
      end
      self.assign(controller_class: cls)
    end
  end
end
