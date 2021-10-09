# frozen_string_literal: true

require_relative 'ship'
require_relative 'stack'
require_relative 'subject'

module MarsBase10
  class GraphRover
    attr_reader :panes, :ship, :viewport

    def initialize(ship_connection:, viewport:)
      @ship = Ship.new connection: ship_connection
      @stack = Stack.new
      @viewport = viewport
      @viewport.controller = self

      @panes = []

      # The graph list is a fixed width, variable height (full screen) pane on the left.
      @graph_list_pane = @viewport.add_pane width_pct: 0.3
      @graph_list_pane.viewing subject: @ship.graph_names

      # The node list is a variable width, fixed height pane in the upper right.
      @node_list_pane = @viewport.add_variable_width_pane at_col: @graph_list_pane.last_col,
                                                          height_pct: 0.5
      @node_list_pane.viewing subject: @ship.node_list

      # The single node viewer is a variable width, variable height pane in the lower right.
      @node_view_pane = @viewport.add_variable_both_pane at_row: @node_list_pane.last_row,
                                                         at_col: @graph_list_pane.last_col
      @node_view_pane.viewing subject: @ship.node

      self.viewport.activate pane: @graph_list_pane
      self.resync
    end

    #
    # Called by a pane in this controller for bubbling a key press up
    #
    def send(key:)
      case key
      when 'd'    # (D)ive
        begin
          if @node_view_pane.subject.contents[4].include?('true')
            resource = @graph_list_pane.current_subject
            node_index = @node_list_pane.current_subject
            @stack.push(resource)
            @node_list_pane.clear
            @node_list_pane.subject.contents = self.ship.fetch_node_children resource: resource, index: node_index
          end
        end
      when 'i'    # (I)nspect
        begin
          self.viewport.activate pane: @node_list_pane
        end
      when 'g'    # (G)raph View
        self.viewport.activate pane: @graph_list_pane
      when 'p'    # (P)op
        begin
          if (resource = @stack.pop)
            @node_list_pane.clear
            @node_list_pane.subject.contents = self.ship.fetch_node_list(resource: resource)
          end
        end
      end
      self.resync
    end

    def start
      self.viewport.open
    end

    def stop
      self.viewport.close
    end

    private

    def resync
      self.resync_node_view(self.resync_node_list)
    end

    def resync_node_list
      resource = @graph_list_pane.current_subject
      if @graph_list_pane == self.viewport.active_pane
        @node_list_pane.subject.title = "Nodes of #{resource}"
        @node_list_pane.clear
        @node_list_pane.subject.first_row = 0
        @node_list_pane.subject.contents = self.ship.fetch_node_list resource: resource
      end
      resource
    end

    def resync_node_view(resource)
      node_index = @node_list_pane.current_subject
      @node_view_pane.subject.title = "Node #{self.short_index node_index}"
      @node_view_pane.clear
      @node_view_pane.subject.contents = self.ship.fetch_node_contents(resource: resource, index: node_index)
    end

    def short_index(index)
      return "" if index.nil?
      tokens = index.split('.')
      "#{tokens[0]}..#{tokens[tokens.size - 2]}.#{tokens[tokens.size - 1]}"
    end
  end
end
