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

      self.viewport.action_bar = ActionBar.Default.add_action({'i': 'Inspect'})
      self.viewport.activate pane: @graph_list_pane
      self.resync
    end

    def load_history(node_index:)
      node = self.ship.fetch_node(resource: self.resource, index: node_index)
      @node_list_pane.subject.contents = self.ship.fetch_older_nodes(resource: self.resource, node: node) + @node_list_pane.subject.contents
    end

    def resource
      @graph_list_pane.current_subject
    end

    #
    # Called by a pane in this controller for bubbling a key press up
    #
    def send(key:)
      case key
      when 'd'    # (D)ive
        begin
          if @node_view_pane.subject.contents[4].include?('true')
            self.viewport.action_bar.add_action({'p': 'Pop Out'})
            resource = @graph_list_pane.current_subject
            node_index = @node_list_pane.current_subject
            @stack.push(resource)
            @node_list_pane.clear
            @node_list_pane.subject.contents = self.ship.fetch_node_children resource: resource, index: node_index
            @node_list_pane.index = 0
          end
        end
      when 'i'    # (I)nspect
        begin
          self.viewport.activate pane: @node_list_pane
          self.viewport.action_bar = ActionBar.Default.add_action({'d': 'Dive In', 'g': 'Graph List'})
        end
      when 'g'    # (G)raph View
        unless @graph_list_pane.active?
          self.viewport.activate pane: @graph_list_pane
        end
      when 'p'    # (P)op
        begin
          if (resource = @stack.pop)
            @node_list_pane.clear
            @node_list_pane.subject.contents = self.ship.fetch_node_list(resource: resource)
            @node_list_pane.index = 0
          end
          if (@stack.length == 0)
            self.viewport.action_bar.remove_action(:p)
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
      self.resync_node_list
      self.resync_node_view
    end

    def resync_node_list
      if @graph_list_pane == self.viewport.active_pane
        @node_list_pane.subject.title = "Nodes of #{self.resource}"
        @node_list_pane.clear
        @node_list_pane.subject.first_row = 0
        @node_list_pane.subject.contents = self.ship.fetch_node_list resource: self.resource
      end
      nil
    end

    def resync_node_view
      node_index = @node_list_pane.current_subject
      @node_view_pane.subject.title = "Node #{self.short_index node_index}"
      @node_view_pane.clear
      @node_view_pane.subject.contents = self.ship.fetch_node_contents(resource: self.resource, index: node_index)
      nil
    end

    def short_index(index)
      return "" if index.nil?
      tokens = index.split('.')
      "#{tokens[0]}..#{tokens[tokens.size - 2]}.#{tokens[tokens.size - 1]}"
    end
  end
end
