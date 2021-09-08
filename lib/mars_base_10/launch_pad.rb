# frozen_string_literal: true

require 'curses'

module MarsBase10
  class Error < StandardError; end

  class LaunchPad
    MIN_INDEX = 1
    MAX_INDEX = 3

    def self.activate
      Curses.init_screen
      Curses.noecho   # Do not echo characters typed by the user.
      Curses.start_color if Curses.has_colors?

      begin
        win = Curses::Window.new(0,0,0,0)
        @index = 1

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
            @index = @index >= MAX_INDEX ? MAX_INDEX : @index + 1
          when 'k'
            @index = @index <= MIN_INDEX ? MIN_INDEX : @index - 1
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
      ensure
        Curses.close_screen
      end
    end
  end
end
