# frozen_string_literal: true

require_relative 'ship'
require_relative 'subject'

module MarsBase10
  class GraphRover
    attr_reader :panes, :ship, :viewport

    def initialize(ship_connection:, viewport:)
      @ship = Ship.new connection: ship_connection
      @viewport = viewport
      @viewport.controller = self

      @panes = []
      @graph_list_pane = @viewport.add_pane width_pct: 0.3
      @graph_list_pane.viewing subject: @ship.graph_names

      @node_list_pane = @viewport.add_right_pane(at_col: @graph_list_pane.last_col, height_pct: 0.5)
      @node_list_pane.viewing subject: @ship.node_list

      @node_view_pane = @viewport.add_right_pane(at_row: @node_list_pane.last_row, at_col: @graph_list_pane.last_col, height_pct: 0.5)
      @node_view_pane.viewing subject: @ship.node
    end

    #
    # Called by a pane in this controller for bubbling a key press up
    #
    def send(key:)
      case key
      when 'i'    # Inspect
        resource = @graph_list_pane.subject.at index: @graph_list_pane.index
        if @graph_list_pane == self.viewport.active_pane
          @node_list_pane.subject.title = "Nodes of #{resource}"
          @node_list_pane.clear
          @node_list_pane.subject.contents = self.ship.fetch_node_list resource: resource
        end

        node_index = @node_list_pane.subject.at index: @node_list_pane.index
        @node_view_pane.subject.title = "Node #{self.short_index node_index}"
        @node_view_pane.clear
        @node_view_pane.subject.contents = self.ship.fetch_node(resource: resource, index: node_index)

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

    private

    def short_index(index)
      tokens = index.split('.')
      "#{tokens[0]}..#{tokens[tokens.size - 2]}.#{tokens[tokens.size - 1]}"
    end
  end
end
