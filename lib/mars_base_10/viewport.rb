# frozen_string_literal: true
require 'curses'
require_relative 'pane'

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

  class ViewPort
    attr_accessor :panes

    def initialize(ship:)
      Curses.init_screen
      Curses.noecho   # Do not echo characters typed by the user.
      Curses.start_color if Curses.has_colors?
      @panes = []
      @panes << (MarsBase10::Pane.new displaying: (Subject.new wrapping: ship),
                          at_row:     self.min_row,
                          at_col:     self.min_col)
    end

    def close
      Curses.close_screen
    end

    def max_cols
      self.win.maxx
    end

    def max_rows
      self.win.maxy
    end

    def min_col
      0
    end

    def min_row
      0
    end

    def open
      loop do
        self.panes.each do |pane|
          pane.display
        end
      end
    end
  end
end
