# frozen_string_literal: true
require 'curses'

module MarsBase10
  class Pane
    attr_accessor :draw_row, :draw_col, :first_col, :top_row, :index, :subject, :win

    def initialize(displaying:, at_row:, at_col:)
      @first_col = at_col
      @top_row = at_row
      @index = 1
      @subject = displaying
      @win = Curses::Window.new(self.max_rows, self.max_cols, at_row, at_col)
      @win.scrollok true
    end

    def display
      loop do
        self.draw_border

        # self.subject.contents.each do |item|
        # [self.first_row..self.max_content_rows].each do |item|
        (1..10).each do |item|
          self.win.setpos(self.draw_row, self.draw_col)
          self.win.addstr("#{"%02d" % item} #{self.subject.contents[item - 1]}")        # Display the row_number and then the text
          self.draw_row += 1
        end

        win.setpos(self.index, 1)
        win.refresh  # Refresh the screen
        self.process
      end
    end

    def draw_border
      self.win.box
      self.win.setpos(0, 2)
      self.win.addstr(" #{self.subject.title} ")
      self.draw_row = 1
      self.draw_col = 1
    end

    def first_row
      self.top_row + 1
    end

    def max_cols
      6 + self.subject.cols
    end

    def max_contents_rows
      [10, (self.subject.rows + 2)].min
    end

    def max_rows
      2 + self.max_contents_rows
    end

    def process
      str = win.getch.to_s
      case str
      when 'j'
        self.set_row(self.index + 1)
      when 'k'
        self.set_row(self.index - 1)
      # when 'i'
      #   win1 = self.win.subwin(10, 20, 10, 20)
      #   win1.box
      #   win1.setpos(1, 1)
      #   win1.addstr("Hello World")  # Display the text
      #   win1.refresh
      #   # win.redraw
      #   input = win1.getch
      when 'q'
        exit 0
      else
        self.set_row(str.to_i)
      end
    end

    #
    # this is a no-op if the index is out of range
    #
    def set_row(i)
      i = 10 if (0 == i)
      i = 1 if (11 == i)
      self.index = i if (i <= self.subject.rows) && (i > 0)
    end
  end

end
