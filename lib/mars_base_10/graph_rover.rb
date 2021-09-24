# frozen_string_literal: true
require_relative 'subject'

module MarsBase10
  class GraphRover
    attr_accessor :panes, :viewport

    def initialize(ship:, viewport:)
      @ship = ship
      @viewport = viewport

      @panes = []
      @p1 = @viewport.add_pane(subject: (ShipSubject.new ship: ship))

      s = Subject.new title: 'Nodes', contents: ['aaaaaaaaaaaaaaaaaaaaaa', 'bbbbbbbbbbb', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm']
      @p2 = @viewport.add_right_pane(subject: s, at_col: @p1.last_col + 1)
    end

    def start
      self.viewport.open
    end

    def stop
      self.viewport.close
    end
  end
end
