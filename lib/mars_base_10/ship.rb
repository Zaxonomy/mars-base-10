# frozen_string_literal: true

require_relative 'subject'

module MarsBase10
  class Ship
    def initialize(connection:)
      @ship = connection
    end

    def empty_node
      Subject.new title: 'Node', contents: []
    end

    def empty_node_list
      Subject.new title: 'Node List', contents: []
    end

    def graph_names
      Subject.new title: 'Graphs', contents: @ship.graph_names
    end

    def group_names
      Subject.new title: 'Groups', contents: (@ship.groups.map {|g| g.to_list})
    end

    def fetch_channel(group_title:, channel_title:)
      if (group = @ship.groups[title: group_title])
        if (channel = group.graphs.select {|c| channel_title == c.title unless c.nil?}.first)
          return channel
        end
      end
      nil
    end

    def fetch_channel_props(group_title:, channel_title:)
      if (channel = self.fetch_channel(group_title: group_title, channel_title: channel_title))
        # What we are calling a channel here is really a graph in the urbit-ruby bridge.
        # This is the equivalent of node.to_pretty_array
        props = {
          title:       channel.title,
          description: channel.description,
          creator:     channel.creator,
          host_ship:   channel.host_ship,
          resource:    channel.resource,
          type:        channel.type
        }
        return props.each.map {|k, v| "#{k}#{(' ' * [(18 - k.length), 0].max)}#{v}"}
      end
      ["Channel not found."]
    end

    def fetch_group(group_title:)
      if (group = @ship.groups[title: group_title])
        # This is the equivalent of node.to_pretty_array
        return group.to_h.each.map {|k, v| "#{k}#{(' ' * [(18 - k.length), 0].max)}#{v}"}
      end
      ["Group not found."]
    end

    def fetch_group_channels(group_title:)
      if (group = @ship.groups[title: group_title])
        return group.graphs.map {|g| g.nil? ? "Unnamed" : g.title}
      end
      ["No Channels Available."]
    end

    def fetch_node(resource:, index:)
      @ship.graph(resource: resource).node(index: index)
    end

    def fetch_node_children(resource:, index:)
      self.fetch_node(resource: resource, index: index).children.map {|node| node.index}.sort
    end

    def fetch_node_contents(resource:, index:)
      return [] unless (n = self.fetch_node(resource: resource, index: index))
      n.to_pretty_array
    end

    def fetch_node_list(resource:)
      @ship.graph(resource: resource).newest_nodes(count: 60).map {|node| node.index}.sort
    end

    def fetch_older_nodes(resource:, node:)
      @ship.graph(resource: resource).older_sibling_nodes(node: node, count: 60).map {|node| node.index}.sort
    end
  end
end
