# frozen_string_literal: true
require 'curses'

module MarsBase10
  class Pane
    attr_accessor :draw_row, :draw_col, :edge_col, :top_row, :index, :subject, :win

    def initialize(displaying:, at_row:, at_col:)
      @top_row = at_row
      @edge_col = at_col
      @index = 0
      @subject = displaying
      @win = Curses::Window.new(self.last_row, self.last_col, at_row, at_col)
      @win.scrollok true
    end

    def display
      loop do
        self.draw_border

        (0..(self.max_contents_rows - 1)).each do |item|
          self.win.setpos(self.draw_row, self.draw_col)
          self.win.addstr("#{"%2d" % item} #{self.subject.contents[item]}")        # Display the row_number and then the text
          self.draw_row += 1
        end

        win.setpos(self.index + 1, self.first_col)
        win.refresh  # Refresh the screen
        self.process
      end
    end

    def draw_border
      self.win.box
      self.draw_title
      self.draw_row = self.first_row
      self.draw_col = self.first_col
    end

    def draw_title
      self.win.setpos(0, 2)
      self.win.addstr(" #{self.subject.title} ")
    end

    def first_col
      self.edge_col + 1
    end

    def first_row
      self.top_row + 1
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
      [10, (self.subject.rows + 3)].min
    end

    def process
      str = win.getch.to_s
      case str
      when 'j'
        self.set_row(self.index + 1)
      when 'k'
        self.set_row(self.index - 1)
      when 'q'
        exit 0
      else
        self.set_row(str.to_i)
      end
    end

    def right_pad
      2
    end

    #
    # this is a no-op if the index is out of range
    #
    def set_row(i)
      i = 9 if (i < 0)
      i = 0 if (i > 9)
      self.index = i if (i <= self.max_contents_rows) && (i >= 0)
    end
  end

end
