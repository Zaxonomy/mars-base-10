# frozen_string_literal: true

require_relative 'ship'
require_relative 'stack'
require_relative 'subject'

module MarsBase10
  class Controller
    attr_reader :manager, :panes, :ship, :viewport

    def initialize(manager:, ship_connection:, viewport:)
      @manager = manager
      @ship = Ship.new connection: ship_connection
      @stack = Stack.new
      @viewport = viewport
      @viewport.controller = self

      self.wire_up_panes
      self.action_bar = ActionBar.Default.add_action({'i': 'Inspect'})
      self.viewport.activate pane: @pane_1
      self.resync
    end


    def action_bar
      self.viewport.action_bar
    end

    def action_bar=(an_action_bar)
      self.viewport.action_bar = an_action_bar
    end

    def resync
    end

    def start
      self.viewport.open
    end

    def stop
      self.viewport.close
    end
  end
end
