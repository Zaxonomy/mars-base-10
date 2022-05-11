# frozen_string_literal: true

require_relative 'ship'
require_relative 'stack'
require_relative 'subject'

module MarsBase10
  class GroupRoom
    attr_reader :panes, :ship, :viewport

    def initialize(ship_connection:, viewport:)
      @ship = Ship.new connection: ship_connection
      @stack = Stack.new
      @viewport = viewport
      @viewport.controller = self

      self.wire_up_panes
      self.viewport.action_bar = ActionBar.Default.add_action({'i': 'Inspect'})
      self.viewport.activate pane: @pane_1
      self.resync
    end

    def active_node_index
      @pane_2.current_subject_index
    end

    def active_node
      self.ship.fetch_node(resource: self.active_resource, index: self.active_node_index)
    end

    def active_resource
      @pane_1.current_subject_index
    end

    def load_history
      return 0 unless @pane_2 == self.viewport.active_pane
      new_content = self.ship.fetch_older_nodes(resource: self.active_resource, node: self.active_node)
      @pane_2.subject.prepend_content(ary: new_content)
      new_content.length
    end

    #
    # Called by a pane in this controller for bubbling a key press up
    #
    def send(key:)
      resync_needed = true
      case key
      when 'd'    # (D)ive
        begin
          if @node_view_pane.subject.contents[4].include?('true')
            self.viewport.action_bar.add_action({'p': 'Pop Out'})
            @stack.push(self.active_resource)
            @pane_2.clear
            @pane_2.subject.contents = self.ship.fetch_node_children(resource: self.active_resource, index: self.active_node_index)
          end
        end
      when 'i'    # (I)nspect
        begin
          self.viewport.activate pane: @pane_2
          self.viewport.action_bar = ActionBar.Default.add_action({'d': 'Dive In', 'g': 'Graph List'})
          resync_needed = false
        end
      when 'g'    # (G)raph View
        unless @pane_1.active?
          self.viewport.activate pane: @pane_1
          # resync_needed = false
        end
      when 'p'    # (P)op
        begin
          if (resource = @stack.pop)
            @pane_2.clear
            @pane_2.subject.contents = self.ship.fetch_node_list(resource: resource)
          end
          if (@stack.length == 0)
            self.viewport.action_bar.remove_action(:p)
          end
        end
      end
      self.resync if resync_needed
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
      # self.resync_node_view
    end

    def resync_node_list
      if @pane_1 == self.viewport.active_pane
        @pane_2.clear
        @pane_2.subject.title = "Channels of #{self.active_resource}"
        @pane_2.subject.contents = self.ship.fetch_group_channels(group_title: self.active_resource)
      end
      nil
    end

    def resync_node_view
      @node_view_pane.subject.title = "Node #{self.short_index self.active_node_index}"
      @node_view_pane.clear
      @node_view_pane.subject.contents = self.ship.fetch_node_contents(resource: self.active_resource, index: self.active_node_index)
      nil
    end

    def short_index(index)
      return "" if index.nil?
      tokens = index.split('.')
      "#{tokens[0]}..#{tokens[tokens.size - 2]}.#{tokens[tokens.size - 1]}"
    end

    def wire_up_panes
      @panes = []

      # Pane #1 is the Group list, It is a fixed width, variable height (full screen) pane on the left.
      @pane_1 = @viewport.add_pane width_pct: 0.3
      if @ship.group_names.empty?
        @pane_1.view(subject: @ship.graph_names)
      else
        @pane_1.view(subject: @ship.group_names)
      end

      # The node list is a variable width, fixed height pane in the upper right.
      @pane_2 = @viewport.add_variable_width_pane at_col: @pane_1.last_col, height_pct: 0.5
      @pane_2.view(subject: @ship.empty_node_list)

      # The single node viewer is a variable width, variable height pane in the lower right.
      @node_view_pane = @viewport.add_variable_both_pane at_row: @pane_2.last_row, at_col: @pane_1.last_col
      @node_view_pane.view(subject: @ship.empty_node)
    end
  end
end
