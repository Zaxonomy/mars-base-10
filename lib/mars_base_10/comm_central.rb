# frozen_string_literal: true

require 'curses'

module MarsBase10
  class Error < StandardError; end

  class CommCentral
    attr_accessor :viewport

    def initialize
      @viewport = MarsBase10::ViewPort.new
    end

    def activate
      self.viewport.open
    end

    def shutdown
      self.viewport.close
    end
  end

  class ViewPort
    MIN_INDEX = 1
    MAX_INDEX = 3

    attr_accessor :index, :win

    def initialize
      Curses.init_screen
      Curses.noecho   # Do not echo characters typed by the user.
      Curses.start_color if Curses.has_colors?
      @win = Curses::Window.new(0,0,0,0)
      @index = 1
    end

    def close
      Curses.close_screen
    end

    def open
      loop do
        win.box
        nb_cols = win.maxx
        nb_lines = win.maxy

        win.setpos(1, 1)
        win.addstr("Hello World")  # Display the text

        win.setpos(2, 1)
        win.addstr("Number of rows: #{nb_lines}")

        win.setpos(3, 1)
        win.addstr("Number of columns: #{nb_cols}")

        win.setpos(@index, 1)
        win.refresh  # Refresh the screen

        str = win.getch.to_s
        case str
        when 'j'
          self.index = self.index >= MAX_INDEX ? MAX_INDEX : self.index + 1
        when 'k'
          self.index = self.index <= MIN_INDEX ? MIN_INDEX : self.index - 1
        when 'i'
          win1 = win.subwin(10, 20, 10, 20)
          win1.box
          win1.setpos(1, 1)
          win1.addstr("Hello World")  # Display the text
          win1.refresh
          # win.redraw
          input = win1.getch
        when 'q' then exit 0
        end
      end
    end
  end
end
