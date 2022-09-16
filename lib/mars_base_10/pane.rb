# frozen_string_literal: true
require 'curses'

module MarsBase10
  class Pane
    attr_accessor :cur_draw_row, :cur_draw_col, :extended_lines, :highlight, :index, :latch, :subject
    attr_reader   :height_pct, :left_edge_col, :top_row, :viewport, :width_pct

    def initialize(viewport:, at_row:, at_col:, height_pct: 1, width_pct: 1)
      @first_visible_index   = 1
      @height_pct            = height_pct
      @highlight             = false
      @index                 = 1
      @last_visible_index    = 0
      @latch                 = ''
      @latch_depth           = 0
      @left_edge_col         = at_col
      @subject               = nil
      @top_row               = at_row
      @win                   = nil
      @viewport              = viewport
      # @visible_content_shift = 0
      @width_pct             = width_pct
    end

    def active?
      self == self.viewport.active_pane
    end

    def clear
      self.reset
      self.prepare_for_writing_contents
      (0..(self.last_row - 1)).each do |item|
        self.window.setpos(self.cur_draw_row, self.cur_draw_col)
        self.window.addstr("")
        self.window.clrtoeol
        self.cur_draw_row += 1
      end
    end

    def current_item_index
      (self.cur_draw_row - self.extended_lines) + self.visible_content_shift
    end

    def current_subject_index
      self.subject.at(index: self.index)
    end

    def draw
      self.prepare_for_writing_contents

      while self.cur_draw_row <= self.last_drawable_row
        if self.current_item_index <= self.subject.item_index_range.last
          if (self.current_item_index == self.index) && !self.highlight
            self.window.attron(Curses::A_REVERSE)
            self.highlight = true
          end

          if self.subject.line_length_at(index: self.current_item_index) > self.last_col
            chunks = self.subject.line_at(index: self.current_item_index).chars.each_slice(self.last_col - 2).map(&:join)
            chunks.each do |c|
              self.draw_line
              self.window.addstr("#{c}")
              self.cur_draw_row += 1
              self.extended_lines += 1
            end
            self.extended_lines -= 1
          else
            self.draw_line
            self.window.addstr("#{self.subject.line_at(index: self.current_item_index)}")
            self.cur_draw_row += 1
          end

          if self.highlight
            self.window.attroff(Curses::A_REVERSE)
            self.highlight = false
          end
        else
          self.draw_line
          self.window.addstr(" ")
          self.cur_draw_row += 1
        end
        self.window.clrtoeol
      end
      self.draw_border

      @last_visible_index = self.current_item_index - 1  # Subtract one b/c we have already incremented before loop
    end

    def draw_border
      self.window.attron(Curses.color_pair(1) | Curses::A_BOLD) if self.active?
      self.window.box
      self.draw_title
      self.window.attroff(Curses.color_pair(1) | Curses::A_BOLD) if self.active?
    end

    def draw_line
      self.window.setpos(self.cur_draw_row, self.cur_draw_col)
    end

    def draw_title
      self.window.setpos(0, 2)
      self.window.addstr(" #{self.subject.title} (#{self.max_contents_rows} total) ")
    end

    def first_drawable_col
      1
    end

    def first_drawable_row
      1
    end

    def gutter_width
      self.subject.index_width
    end

    #
    # This is the _relative_ last column, e.g. the width of the pane in columns.
    #
    def last_col
      # [(self.viewport.max_cols * self.width_pct).floor, self.min_column_width].max
      (self.viewport.max_cols * self.width_pct).floor
    end

    def last_drawable_row
      [self.last_visible_row, self.max_contents_rows].min
    end

    #
    # This is the _relative_ last row, e.g. the height of the pane in rows
    #
    def last_row
      (self.viewport.max_rows * self.height_pct).floor
    end

    #
    # This is the height of the pane minus the border
    #
    def last_visible_row
      self.last_row - 2
    end

    #
    # The pane is latched if it has consumed 1 key 0-9 and is awaiting the next key.
    #
    def latched?
      @latch_depth > 0
    end

    def max_contents_rows
      self.subject.item_index_range.last
    end

    def min_column_width
      self.gutter_width + self.subject.max_content_width + self.right_pad
    end

    def prepare_for_writing_contents
      self.cur_draw_row = self.first_drawable_row
      self.cur_draw_col = self.first_drawable_col
      self.extended_lines = 0
      @first_visible_index = self.cur_draw_row + self.visible_content_shift
      @last_visible_index = self.subject.item_count if @last_visible_index < @first_visible_index
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
        self.index = self.set_row(self.index + 1)
      when 'k'
        self.index = self.set_row(self.index - 1)
      when 'J'
        self.index = self.set_row([self.index + (self.last_visible_row), self.max_contents_rows].min)
      when 'K'
        self.index = self.set_row(self.index - self.visible_content_range.count)
      when 'q'
        exit 0
      when ('0'..'9')
        if self.latched?
          self.latch << key
          @latch_depth += 1
          if @latch_depth == self.gutter_width
            self.index = self.set_row(self.latch.to_i)
            self.latch = ""
            @latch_depth = 0
          end
        else
          self.latch = key
          @latch_depth = 1
        end
      end

      # Always send the key to the controller for additional processing...
      self.viewport.controller.send key: key
    end

    def reset
      @index = 1
      @latch = ''
      @latch_depth = 0
      # @visible_content_shift = 0
    end

    def right_pad
      2
    end

    def scroll_to_row(index)
      jump = [(index - self.index), (self.max_contents_rows - self.visible_content_range.last)].min
      if index > self.index
        # Scrolling down
        if index > self.visible_content_range.last
          @first_visible_index = @first_visible_index + jump
          @last_visible_index = @last_visible_index + jump
        end
      else
        # Scrolling up
        if index < self.visible_content_range.first
            @first_visible_index = [(@first_visible_index + jump), 1].max
            @last_visible_index = @last_visible_index + jump
        end
      end
      [index, 1].max
    end

    #
    # this is a no-op if the index is out of range
    #
    def set_row(i)
      return i if self.visible_content_range.include?(i)

      # If we've reached the end of the content, it's a no-op.
      current_index = self.index
      return self.max_contents_rows if (i > self.max_contents_rows)

      # Check if we have tried to move "above" the visible screen limit (i = 1) and retrieve more items, if possible.
      if (i < 1)
        if i < 0
          target_index = self.index
          self.index = 1
        end
        i = [self.viewport.controller.load_history, 1].max
        i = target_index if target_index
      end

      return self.scroll_to_row(i)
    end

    def view(subject:)
      @subject = subject
    end

    def visible_content_range
      # ((self.first_drawable_row + @visible_content_shift)..(self.last_drawable_row + @visible_content_shift))
      (@first_visible_index..@last_visible_index)
    end

    def visible_content_shift
      self.visible_content_range.first - self.first_drawable_row
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

  class VariableHeightPane < Pane
    def last_col
      (self.viewport.max_cols * self.width_pct).floor
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
