# frozen_string_literal: true
require 'curses'

module MarsBase10
  class Pane
    attr_accessor :draw_row, :draw_col, :index
    attr_reader   :edge_col, :subject, :top_row, :viewport

    def initialize(at_row:, at_col:, viewport:)
      @top_row  = at_row
      @edge_col = at_col
      @index    = 0
      @subject  = nil
      @win      = nil
      @viewport = viewport
    end

    def clear
      self.prepare_for_writing_contents
      (0..(self.max_contents_rows - 1)).each do |item|
        self.window.setpos(self.draw_row, self.draw_col)
        self.window.addstr("")
        self.window.clrtoeol
        self.draw_row += 1
      end
      self.draw_border
    end

    def draw
      self.prepare_for_writing_contents

      (0..(self.max_contents_rows - 1)).each do |item|
        self.window.setpos(self.draw_row, self.draw_col)
        # The string here is the gutter followed by the window contents. improving the gutter is tbd.
        self.window.attron(Curses::A_REVERSE) if item == self.index
        self.window.addstr("#{"%2d" % item} #{self.subject.at index: item}")
        self.window.attroff(Curses::A_REVERSE) if item == self.index
        self.window.clrtoeol
        self.draw_row += 1
      end

      self.draw_border
    end

    def draw_border
      self.window.box
      self.draw_title
    end

    def draw_title
      self.window.setpos(0, 2)
      self.window.addstr(" #{self.subject.title} (#{self.subject.rows} total) ")
    end

    def first_col
      1
    end

    def first_row
      1
    end

    def gutter_width
      4
    end

    def last_col
      self.gutter_width + self.subject.cols + self.right_pad
    end

    def last_row
      2 + self.max_contents_rows
    end

    def max_contents_rows
      [10, self.subject.rows].min
    end

    def prepare_for_writing_contents
      self.draw_row = self.first_row
      self.draw_col = self.first_col
    end

    #
    # process blocks and waits for a keypress.
    #
    # this method handles only the "default" keypresses which all controllers/subjects
    #   must support. Any unrecognized key is bubbled to the controller for more specific
    #   handling.
    #
    def process
      key = self.window.getch.to_s
      case key
      when [0..9]
        self.set_row(key.to_i)
      when 'j'
        self.set_row(self.index + 1)
      when 'k'
        self.set_row(self.index - 1)
      when 'q'
        exit 0
      else
        self.subject.controller.send key: key
      end
    end

    def right_pad
      2
    end

    #
    # this is a no-op if the index is out of range
    #
    def set_row(i)
      self.subject.scroll_limit = self.max_contents_rows

      if (i < 0)
       self.subject.scroll_up
       i = 0
      end

      if (i > 9)
        self.subject.scroll_down
        i = 9
      end

      self.index = i if (i <= self.max_contents_rows) && (i >= 0)
    end

    def viewing(subject:)
      @subject = subject
    end

    def window
      return @win if @win
      @win = Curses::Window.new(self.last_row, self.last_col, self.top_row, self.edge_col)
    end
  end

  class VariablePane < Pane
    def last_col
      self.viewport.max_cols - self.edge_col
    end

    def last_row
      self.viewport.max_rows
    end
  end
end
