# frozen_string_literal: true
require 'curses'

require_relative 'pane'
require_relative 'subject'

module MarsBase10
  class ViewPort
    attr_accessor :panes
    attr_reader   :win

    CURSOR_INVISIBLE = 0
    CURSOR_VISIBLE   = 1

    def initialize(ship:)
      Curses.init_screen
      Curses.curs_set(CURSOR_INVISIBLE)
      Curses.noecho   # Do not echo characters typed by the user.
      Curses.start_color if Curses.has_colors?

      @panes = []
      p1 = (MarsBase10::Pane.new displaying: (ShipSubject.new wrapping: ship),
                                 at_row:     self.min_row,
                                 at_col:     self.min_col)
      @panes << p1

      p2 = (MarsBase10::Pane.new displaying: (Subject.new title: 'Nodes', wrapping: ['aaaaaaaaaaaaaaaaaaaaaa', 'bbbbbbbbbbb', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm']),
                                 at_row:     self.min_row,
                                 at_col:     p1.last_col + 1)
      @panes << p2
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
          pane.draw
          pane.win.refresh
        end
        self.panes.first.process
      end
    end
  end
end
