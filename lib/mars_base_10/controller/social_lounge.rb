# frozen_string_literal: true

require_relative '../controller'

module MarsBase10
  # module Controller
    class SocialLounge
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
      end

      def active_node
        self.ship.fetch_node(resource: self.active_resource, index: self.active_node_index)
      end

      def active_resource
        @pane_1.current_subject_index
      end

      def active_subject(pane:)
        pane.current_subject_index
      end

      def load_history
        return 0 unless @pane_3 == self.viewport.active_pane
        new_content = self.ship.fetch_older_nodes(resource: self.active_resource, node: self.active_node)
        @pane_3.subject.prepend_content(ary: new_content)
        new_content.length
      end

      #
      # Called by a pane in this controller for bubbling a key press up
      #
      def send(key:)
        case key
        when 'g'    # (G)raph View
          unless @pane_1.active?
            self.viewport.activate pane: @pane_1
          end
        when 'i'    # (I)nspect
          begin
            self.viewport.activate pane: @pane_3
            self.action_bar = ActionBar.Default.add_action({'g': 'Group List'})
          end
        when 'X'
          self.manager.swap_controller
        end
      end

      private

      def wire_up_panes
        @panes = []
        # Pane #1 is the Chat Channel Reader. It takes up the entire Viewport. (For now?)
        @pane_1 = @viewport.add_pane height_pct: 1.0, width_pct: 1.0
        @pane_1.view(subject: @ship.group_names)
      end
    end
  # end # Module Controller
end   # Module Mars::Base::10
