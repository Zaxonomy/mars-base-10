# frozen_string_literal: true
require 'curses'

module MarsBase10
  class ViewPort
    attr_accessor :draw_col, :draw_row, :index, :win

    def initialize
      Curses.init_screen
      Curses.noecho   # Do not echo characters typed by the user.
      Curses.start_color if Curses.has_colors?
      @win = Curses::Window.new(0,0,0,0)
      @draw_col = 1
      @draw_row = 1
      @index = 1
    end

    def clear
      self.win.box
      self.draw_row = 1
      self.draw_col = 1
    end

    def close
      Curses.close_screen
    end

    def contents
      ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    end

    def max_cols
      self.win.maxx
    end

    def max_rows
      self.win.maxy
    end

    def open
      loop do
        self.clear

        self.contents.each do |item|
          self.win.setpos(self.draw_row, self.draw_col)
          self.win.addstr(item)  # Display the text
          self.draw_row += 1
        end

        win.setpos(self.index, 1)
        win.refresh  # Refresh the screen
        self.process
      end
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
    # This is a no-op if the index is out of range
    #
    def set_row(i)
      i = 10 if (0 == i)
      i = 1 if (11 == i)
      self.index = i if (i <= self.contents.size) && (i > 0)
    end
  end
end
