# frozen_string_literal: true
require_relative 'subject'

module MarsBase10
  class GraphRover
    attr_accessor :panes, :viewport

    def initialize(ship:, viewport:)
      @ship = ship
      @viewport = viewport

      @panes = []
      @graph_list_pane = @viewport.add_pane
      @graph_list_pane.viewing subject: (ShipSubject.new ship: ship)

      @node_list_pane = @viewport.add_right_pane(at_col: @graph_list_pane.last_col)
      @node_list_pane.viewing subject: (Subject.new title: 'Nodes', contents: ['aaaaaaaaaaaaaaaaaaaaaa', 'bbbbbbbbbbb', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm'])
    end

    def start
      self.viewport.open
    end

    def stop
      self.viewport.close
    end
  end
end
