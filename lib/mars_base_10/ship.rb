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

    def fetch_node_list(resource:)
      @ship.graph(resource: resource).newest_nodes(count: 20).map {|node| node.index}
    end

    def fetch_node(resource:, index:)
      @ship.graph(resource: resource).node(index: index).to_h.values
    end
  end
end
