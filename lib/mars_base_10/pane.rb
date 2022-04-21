# frozen_string_literal: true
require 'curses'

module MarsBase10
  class Pane
    attr_accessor :draw_row, :draw_col, :index, :latch, :subject
    attr_reader   :height_pct, :left_edge_col, :top_row, :viewport, :width_pct

    def initialize(viewport:, at_row:, at_col:, height_pct: 1, width_pct: 1)
      @top_row       = at_row
      @left_edge_col = at_col
      @height_pct    = height_pct
      @index         = 0
      @latch         = -1
      @subject       = nil
      @win           = nil
      @viewport      = viewport
      @width_pct     = width_pct
    end

    def active?
      self == self.viewport.active_pane
    end

    def clear
      self.prepare_for_writing_contents
      (0..(self.last_row - 1)).each do |item|
        self.window.setpos(self.draw_row, self.draw_col)
        self.window.addstr("")
        self.window.clrtoeol
        self.draw_row += 1
      end
    end

    def current_subject
      self.subject.at index: self.index
    end

    def draw
      self.prepare_for_writing_contents

      (0..(self.max_contents_rows - 1)).each do |item|
        self.window.setpos(self.draw_row, self.draw_col)
        self.window.attron(Curses::A_REVERSE) if item == self.index
        self.window.addstr(self.subject.line_at index: item)
        self.window.attroff(Curses::A_REVERSE) if item == self.index
        self.window.clrtoeol
        self.draw_row += 1
      end

      self.draw_border
    end

    def draw_border
      self.window.attron(Curses.color_pair(1) | Curses::A_BOLD) if self.active?
      self.window.box
      self.draw_title
      self.window.attroff(Curses.color_pair(1) | Curses::A_BOLD) if self.active?
    end

    def draw_title
      self.window.setpos(0, 2)
      self.window.addstr(" #{self.subject.title} (#{self.max_contents_rows} total) ")
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

    #
    # This is the _relative_ last column, e.g. the width of the pane in columns.
    #
    def last_col
      [(self.viewport.max_cols * self.width_pct).floor, self.min_column_width].max
    end

    #
    # This is the _relative_ last row, e.g. the height of the pane in columns.
    #
    def last_row
      (self.viewport.max_rows * self.height_pct).floor
    end

    def last_visible_row
      self.last_row - 2
    end

    #
    # The pane is latched if it has consumed 1 key 0-9 and is awaiting the next key.
    #
    def latched?
      self.latch != -1
    end

    def max_contents_rows
      self.subject.items
    end

    def min_column_width
      self.gutter_width + self.subject.cols + self.right_pad
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
      when 'j'
        self.set_row(self.index + 1)
      when 'k'
        self.set_row(self.index - 1)
      when 'q'
        exit 0
      when ('0'..'9')
        if self.latched?
          self.set_row((self.latch * 10) + key.to_i)
          self.latch = -1
        else
          self.latch = key.to_i
        end
      end

      # Always send the key to the controller for additional processing...
      self.viewport.controller.send key: key
    end

    def right_pad
      2
    end

    #
    # this is a no-op if the index is out of range
    #
    def set_row(i)
      self.subject.scroll_limit = [self.last_visible_row, self.max_contents_rows].min

      # Check if we have tried to move "above" the visible screen limit (i = 0)
      if (i < 0)
        i = 0  # The first visible row is always index 0
        if self.subject.current_item > self.subject.first_item
          # We are not at the top of the subject so we have non-visible items we can scroll to
          self.subject.scroll_up
        else
          # Retrieve more items, if possible
          self.viewport.controller.load_history
          self.subject.scroll_up
        end
      end

      # If we've reached the end of the content, it's a no-op.
      if (i >= self.max_contents_rows)
        i -= 1
      end

      if (i >= self.last_visible_row)
        self.subject.scroll_down
        i -= 1
      end

      self.index = i # if (i <= self.max_contents_rows) && (i >= 0)
    end

    def viewing(subject:)
      @subject = subject
    end

    def window
      return @win if @win
      @win = Curses::Window.new(self.last_row, self.last_col, self.top_row, self.left_edge_col)
    end
  end

  class VariableBothPane < Pane
    def last_col
      self.viewport.max_cols - self.left_edge_col
    end

    def last_row
      self.viewport.max_rows - self.top_row
    end
  end

  class VariableWidthPane < Pane
    def last_col
      self.viewport.max_cols - self.left_edge_col
    end
  end
end
