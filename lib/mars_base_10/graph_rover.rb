# frozen_string_literal: true
require_relative 'subject'

module MarsBase10
  class GraphRover
    attr_reader :panes, :ship, :viewport

    def initialize(ship:, viewport:)
      @ship = ship
      @viewport = viewport

      @panes = []
      @graph_list_pane = @viewport.add_pane
      @graph_list_pane.viewing subject: (ShipSubject.new ship: ship, controller: self)

      @node_list_pane = @viewport.add_right_pane(at_col: @graph_list_pane.last_col)
      @node_list_pane.viewing subject: (Subject.new title:      'Nodes',
                                                    contents:   ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm'],
                                                    controller: self)
    end

    #
    # Called by a pane in this controller for bubbling a key press up
    #
    def send(key:)
      case key
      when 'i'    # Inspect
        resource = @graph_list_pane.subject.at index: @graph_list_pane.index
        @node_list_pane.subject.title = "Nodes of #{resource}"
        @node_list_pane.clear
        @node_list_pane.subject.contents = @graph_list_pane.subject.node_list resource: resource
        self.viewport.activate pane: @node_list_pane
      when 'g'
        self.viewport.activate pane: @graph_list_pane
      end
    end

    def start
      self.viewport.open
    end

    def stop
      self.viewport.close
    end
  end
end
