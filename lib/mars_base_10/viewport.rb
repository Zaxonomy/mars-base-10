# frozen_string_literal: true
require 'curses'

require_relative 'pane'

module MarsBase10
  class Viewport
    attr_accessor :controller
    attr_reader   :panes, :win

    CURSOR_INVISIBLE = 0
    CURSOR_VISIBLE   = 1

    def initialize
      Curses.init_screen
      Curses.curs_set(CURSOR_INVISIBLE)
      Curses.noecho   # Do not echo characters typed by the user.

      Curses.start_color if Curses.has_colors?
      Curses.init_pair(1, Curses::COLOR_RED, Curses::COLOR_BLACK)

      @active_pane = nil
      @controller = nil

      @panes = []

      # this is the whole visible drawing surface.
      # we don't ever draw on this, but we need it for reference.
      @win = Curses::Window.new 0, 0, 0, 0
    end

    def activate(pane:)
      @active_pane = pane
    end

    #
    # This is the pane in the Viewport which is actively accepting keyboard input.
    #
    def active_pane
      @active_pane
    end

    #
    # Adds a new drawable area (Pane) to the viewport.
    # By default it is anchored to the top left. (min_row, min_col)
    #  and full screen. (height and width 100%)
    #
    def add_pane(at_row: self.min_row, at_col: self.min_col, height_pct: 1, width_pct: 1)
      p = MarsBase10::Pane.new viewport:   self,
                               at_row:     at_row,
                               at_col:     at_col,
                               height_pct: height_pct,
                               width_pct:  width_pct
      @panes << p
      @active_pane = p
    end

    def add_variable_width_pane(at_row: self.min_row, at_col: self.min_col, height_pct:)
      p = VariableWidthPane.new viewport: self,
                                  at_row: at_row,
                                  at_col: at_col,
                              height_pct: height_pct
      @panes << p
      p
    end

    #
    # Adds a new variable width drawable area (VariableBothPane) to the
    #   right-hand side of the viewport.
    #
    # The caller must specify the upper left corner (at_row, at_col) but
    #   after that it will automatically adjust its width based upon how
    #   many columns the left pane(s) use.
    #
    def add_variable_both_pane(at_row: self.min_row, at_col: self.min_col)
      p = VariableBothPane.new viewport: self,
                                 at_row: at_row,
                                 at_col: at_col
      @panes << p
      p
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
          pane.window.refresh
        end
        self.active_pane.process
      end
    end

    #
    # Called by a pane in this viewport for bubbling a key press up
    # to the controller.
    #
    def send(key:)
      self.activate pane: self.panes[1]
    end
  end
end
