# frozen_string_literal: true
require 'curses'

require_relative 'pane'

module MarsBase10
  class Viewport
    attr_reader   :panes, :win

    CURSOR_INVISIBLE = 0
    CURSOR_VISIBLE   = 1

    def initialize
      Curses.init_screen
      Curses.curs_set(CURSOR_INVISIBLE)
      Curses.noecho   # Do not echo characters typed by the user.
      Curses.start_color if Curses.has_colors?
      @panes = []
      @active_pane = nil

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
    #
    def add_pane(at_row: self.min_row, at_col: self.min_col)
      p = MarsBase10::Pane.new at_row:     at_row,
                               at_col:     at_col,
                               viewport:   self
      @panes << p
      @active_pane = p
    end

    #
    # Adds a new variable drawable area (VariablePane) to the viewport.
    #
    # The caller must specify the upper left corner (at_row, at_col) but
    #   after that it will expand to the width and height of the viewport.
    #
    def add_right_pane(at_row: self.min_row, at_col: self.min_col)
      p = VariablePane.new at_row:     at_row,
                           at_col:     at_col,
                           viewport:   self
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
