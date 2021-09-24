# frozen_string_literal: true

module MarsBase10
  class Subject
    attr_accessor :first_row, :scroll_limit, :title
    attr_reader   :controller

    def initialize(title: 'Untitled', contents:, controller:)
      @contents   = contents
      @controller = controller
      @first_row  = 0
      @title      = title
    end

    # Returns the item at: the index: relative to the first_row.
    def at(index:)
      self.contents[self.first_row + index]
    end

    def cols
      return @cols if @cols
      @cols = @contents.inject(0) {|a, n| n.length > a ? n.length : a}
    end

    def contents
      @contents
    end

    def contents=(a_contents_array)
      @rows = nil
      $cols = nil
      @contents = a_contents_array
    end

    def rows
      return @rows if @rows
      @rows = @contents.size
    end

    def scroll_down
      self.first_row = [self.first_row + 1, (self.rows - self.scroll_limit)].min
    end

    def scroll_up
      self.first_row = [self.first_row - 1, 0].max
    end
  end

  class ShipSubject < MarsBase10::Subject
    def initialize(ship:, controller:)
      super(title: "Graphs", contents: ship.graph_names, controller: controller)
    end
  end
end
