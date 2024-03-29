# frozen_string_literal: true

require_relative '../controller'

module MarsBase10
    class GroupRoom < Controller
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
        resync_needed = true
        case key
        when 'g'    # (G)raph View
          unless @pane_1.active?
            self.action_bar.remove_actions([:r])
            self.viewport.activate pane: @pane_1
          end
        when 'i'    # (I)nspect
          begin
            resync_needed = false
            self.action_bar.add_action({'g': 'Group List'})
            self.action_bar.add_action({'r': 'Read Channel'})
            self.viewport.activate pane: @pane_3
          end
        when 'r'    # (r)ead -> go to the Social Lounge
          if @pane_3.active?
            resync_needed = false
            self.action_bar.remove_actions([:g, :r])
            opts = {
              group_title:   self.active_subject(pane: @pane_1),
              channel_title: self.active_subject(pane: @pane_3)
            }
            self.manager.assign(controller_class: SocialLounge, options: opts)
          end
        when 'X'
          resync_needed = false
          self.manager.swap_controller
        end
        self.resync if resync_needed
      end

      private

      def resync
        self.resync_node_list
        self.resync_node_view
      end

      def resync_node_list
        if @pane_1 == self.viewport.active_pane
          group_title = self.active_subject(pane: @pane_1)
          @pane_2.clear
          @pane_2.subject.title = "#{group_title}"
          @pane_2.subject.contents = self.ship.fetch_group(group_title: group_title)

          @pane_3.clear
          @pane_3.subject.title = "Channels of #{self.active_subject(pane: @pane_1)}"
          @pane_3.subject.contents = self.ship.fetch_group_channels(group_title: self.active_subject(pane: @pane_1))
        end
        nil
      end

      def resync_node_view
        channel_title = self.active_subject(pane: @pane_3)
        @pane_4.subject.title = "#{channel_title}"
        @pane_4.clear
        @pane_4.subject.contents = self.ship.fetch_channel_props(group_title: self.active_subject(pane: @pane_1), channel_title: channel_title)
        nil
      end

      def wire_up_panes
        @panes = []

        # Pane #1 is the Group list, It is a fixed height and width in the upper left corner.
        @pane_1 = @viewport.add_pane height_pct: 0.5, width_pct: 0.5
        # if @ship.group_names.empty?
          # @pane_1.view(subject: @ship.graph_names)
        # else
          @pane_1.view(subject: @ship.group_names)
        # end

        # Pane 2 displays the properties of the selected Group. It is variable height in the bottom left corner.
        @pane_2 = @viewport.add_variable_height_pane at_row: @pane_1.last_row, width_pct: 0.5
        @pane_2.view(subject: @ship.empty_node)
        @pane_2.highlight = false

        # Pane 3 is the Channel list. It is a variable width, fixed height pane in the upper right.
        @pane_3 = @viewport.add_variable_width_pane at_col: @pane_1.last_col, height_pct: 0.5
        @pane_3.view(subject: @ship.empty_node_list)

        # The single node viewer is a variable width, variable height pane in the lower right.
        @pane_4 = @viewport.add_variable_both_pane at_row: @pane_3.last_row, at_col: @pane_1.last_col
        @pane_4.view(subject: @ship.empty_node)
        @pane_4.highlight = false
      end
    end
end   # Module Mars::Base::10
