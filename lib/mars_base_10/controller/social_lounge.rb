# frozen_string_literal: true

require_relative '../controller'

module MarsBase10
  class SocialLounge < Controller
    attr_accessor :channel

    def initialize(manager:, ship_connection:, viewport:, options: {})
      @index_ary = []
      @group_title = options[:group_title]
      @channel_title = options[:channel_title]
      super(manager: manager, ship_connection: ship_connection, viewport: viewport)
    end

    def active_channel
      if self.channel.nil?
        self.channel = self.ship.fetch_channel(group_title: @group_title, channel_title: @channel_title)
      end
      self.channel
    end

    def active_node_index
      @index_ary[@pane_1.index]
    end

    def active_resource
      self.active_channel.resource # '~winter-paches/top-shelf-6391'
    end

    def active_subject(pane:)
      pane.current_subject_index
    end

    def fetch_channel_messages
      if @pane_1 == self.viewport.active_pane
        @pane_1.clear
        @pane_1.subject.title = "Messages in #{self.active_channel.title}"
        @pane_1.subject.contents = self.load_messages(count: @pane_1.last_visible_row)
      end
      nil
    end

    def load_history
      return 0 unless @pane_1 == self.viewport.active_pane
      messages = self.node_indexes_to_messages(node_indexes: self.ship.fetch_older_nodes(resource: self.active_resource, node: self.active_node, count: @pane_1.last_visible_row))
      @pane_1.subject.prepend_content(ary: messages)
      messages.length
    end

    def load_messages(count:)
      self.node_indexes_to_messages(node_indexes: self.ship.fetch_node_list(resource: self.active_resource, count: count))
    end

    # This will eventually be a native part of the Airlock API
    def message(node:)
      "~#{node.to_h[:author]}  #{self.message_content(node_content: node.to_h[:contents])}"
    end

    def message_content(node_content:)
      n0 = node_content[0]
      if n0["reference"]
        # http://localhost:8080/apps/landscape/perma/group/~winter-paches/the-great-north/graph/~winter-paches/top-shelf-6391/170141184505732100235824355185168220160
        ref = n0["reference"]["graph"]
        # grup = ref["group"].split('/').last
        # graf = ref["graph"].split('/').last
        return "=> #{node_content[2]["mention"]} -> #{node_content[3]["text"]} (#{ref["index"]})"
      end
      n0["text"] || n0["url"]
    end

    def node_indexes_to_messages(node_indexes:)
      @index_ary =  node_indexes + @index_ary
      messages = node_indexes.map do |i|
        # Can't use fetch_node_contents because we're formatting differently now.
        # This will eventually be a native part of the Airlock API
        self.message(node: self.ship.fetch_node(resource: self.active_resource, index: i))
      end
    end

    #
    # Called by a pane in this controller for bubbling a key press up
    #
    def send(key:)
      case key
      when 'g'    # (G)raph View
        unless @pane_1.active?
          self.viewport.activate pane: @pane_1
          self.action_bar.remove_actions([:g])
        end
      when 'i'    # (I)nspect
        begin
          self.viewport.activate pane: @pane_3
          self.action_bar.add_action({'g': 'Group List'})
        end
      when 'X'
        self.manager.swap_controller
      end
    end

    def show
      self.fetch_channel_messages
    end

    private

    def wire_up_panes
      @panes = []
      # Pane #1 is the Chat Channel Reader. It takes up the entire Viewport. (For now?)
      @pane_1 = self.viewport.add_pane height_pct: 1.0, width_pct: 1.0
      @pane_1.view(subject: self.ship.empty_node_list)
    end
  end
end   # Module Mars::Base::10
