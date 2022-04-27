# frozen_string_literal: true

module MarsBase10
  class Subject
    attr_accessor :current_item, :scroll_limit, :title

    def initialize(title: 'Untitled', contents:)
      @contents     = contents
      @title        = title
    end

    def prepend_content(ary:)
      self.contents = ary + self.contents
    end

    # Returns the item at: the index: relative to the current_item.
    def at(index:)
      index = [1, index].max
      self.contents[index - 1]
    end

    def contents
      @contents
    end

    def contents=(a_contents_array)
      @contents = a_contents_array
    end

    def line_at(index:)
      # The string here is the gutter followed by the window contents. improving the gutter is tbd.
      "#{"%04d" % (index)}  #{self.at(index: index)}"
    end

    def line_length_at(index:)
      return 0 if self.at(index: index).nil?
      (self.at(index: index)).length
    end

    def item_count
      @contents.size
    end

    def item_index_range
      1..self.item_count
    end

    def max_content_width
      @contents.inject(0) {|a, n| n.length > a ? n.length : a}
    end
  end
end
