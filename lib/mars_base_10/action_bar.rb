# frozen_string_literal: true

module MarsBase10
  class ActionBar
    attr_accessor :actions

    def initialize(actions:)
      @actions  = actions
      @viewport = nil
      @win      = nil
    end

    def self.Default
      ActionBar.new actions: {'j': 'Move Down', 'k': 'Move Up', 'J': 'Page Down', 'K': 'Page Up', 'X': 'Switch App', 'q': 'Quit'}
    end

    def actions_first_col
      (self.width - self.actions_width)/2
    end

    def actions_width
      self.actions.values.inject(0) {|acc, item| acc += (3 + 2 + item.length + 2)}
    end

    def add_action(a_hash)
      self.actions = Hash[@actions.merge!(a_hash).sort]
      self
    end

    def draw
      self.window.attron(Curses.color_pair(2))
      self.window.setpos(0, 0)
      self.window.addstr("Actions:")
      self.window.addstr(" " * (self.actions_first_col - 8))

      self.actions.each do |key, value|
        self.window.attron(Curses::A_REVERSE)
        self.window.addstr(" #{key} ")
        self.window.attroff(Curses::A_REVERSE) # if item == self.index
        self.window.addstr("  #{value}  ")
      end

      self.window.addstr(" " * (self.width - (self.actions_first_col + self.actions_width)))
      self.window.attroff(Curses.color_pair(2))
    end

    def display_on(viewport:)
      @viewport = viewport
    end

    def first_col
      0
    end

    def first_row
      @viewport.max_rows
    end

    def height
      1
    end

    def remove_action(key)
      self.actions.delete_if {|k, v| k == key}
      self
    end

    def width
      @viewport.max_cols
    end

    def window
      return @win if @win
      @win = Curses::Window.new(self.height, self.width, self.first_row, self.first_col)
    end
  end
end
