# frozen_string_literal: true

require_relative 'subject'

module MarsBase10
  class Ship
    def initialize(connection:)
      @ship = connection
    end

    def graph_names
      Subject.new title: 'Graphs', contents: @ship.graph_names
    end

    def node
      Subject.new title: 'Node', contents: []
    end

    def node_list
      Subject.new title: 'Node List', contents: []
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
