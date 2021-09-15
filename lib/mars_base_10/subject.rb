# frozen_string_literal: true

module MarsBase10
  class Subject
    attr_accessor :cols, :contents, :rows, :title
    def initialize(wrapping:)
      @contents = wrapping.graph_names
      @cols     = @contents.inject(0) {|a, n| n.length > a ? n.length : a}
      @rows     = @contents.size
      @title    = "Graphs"
    end
  end
end
