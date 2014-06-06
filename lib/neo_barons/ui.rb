require_relative "polygon"

module NeoBarons
  class UI < Gosu::Window
    def self.show
      new.show
    end

    def initialize
      super(current_width, current_height, false)
      self.caption = "Neo Barons"

      @hub_image = Gosu::Image.new(
        self,
        File.join(File.dirname(__FILE__), *%w[.. .. data sprites hub.png])
      )
      @pixel_image = Gosu::Image.new(
        self,
        File.join(File.dirname(__FILE__), *%w[.. .. data sprites pixel.png]),
        true
      )

      @highlighted_hub  = nil
      @highlighted_rail = nil
      @checked_rails    = { }
    end

    def update
      @highlighted_hub  = nil
      @highlighted_rail = nil

      scaled_mouse_x   = mouse_x / scaled_width
      scaled_mouse_y   = mouse_y / scaled_height
      row,    y_offset = scaled_mouse_y.divmod(drawn_tile_size)
      scaled_mouse_x   = [0, scaled_mouse_x - drawn_tile_size / 2].max \
        if row.odd?
      column, x_offset = scaled_mouse_x.divmod(drawn_tile_size)
      hub_x_start      = (drawn_tile_size - @hub_image.width) / 2
      hub_y_start      = (drawn_tile_size - @hub_image.height) / 2
      if column < drawn_columns &&
         x_offset.between?(hub_x_start, hub_x_start + @hub_image.width) &&
         y_offset.between?(hub_y_start, hub_y_start + @hub_image.height)
        @highlighted_hub = [column, row]
      end

      if !@highlighted_hub
        if x_offset > drawn_tile_size / 2
          tile_third = drawn_tile_size / 3
          case y_offset
          when 0...tile_third
            row    -= 1
            column += 1 if row.even?
            if row.odd?
              scaled_mouse_x = [0, scaled_mouse_x - drawn_tile_size / 2].max
            else
              scaled_mouse_x = mouse_x / scaled_width
            end
          when tile_third..(2 * tile_third)
            column += 1
          else
            row    += 1
            column += 1 if row.even?
            if row.odd?
              scaled_mouse_x = [0, scaled_mouse_x - drawn_tile_size / 2].max
            else
              scaled_mouse_x = mouse_x / scaled_width
            end
          end
        end
        if column < drawn_columns && row.between?(0, drawn_rows)
          rail_size = Math.sqrt(  drawn_tile_size      ** 2 +
                                 (drawn_tile_size / 2) ** 2 ).round # FIXME:  dup
          rail_x    = column * drawn_tile_size +
                      drawn_tile_size / 2      -
                      drawn_rail_width / 2
          rail_y    = row    * drawn_tile_size + drawn_tile_size / 2
          3.times do |connection|
            angle      = 30 + 60 * connection
            click_x    = rail_x                                        -
                         (highlightable_rail_width - drawn_rail_width) /
                         2
            click_y    = rail_y + @hub_image.height / 2
            click_size = (angle == 90 ? drawn_tile_size : rail_size) -
                         @hub_image.width
            click_area = Polygon.new( [
              [click_x,                            click_y],
              [click_x + highlightable_rail_width, click_y],
              [click_x + highlightable_rail_width, click_y + click_size],
              [click_x,                            click_y + click_size]
            ] )
            click_area.rotate([rail_x + drawn_rail_width / 2, rail_y], angle)
            if click_area.contains?([scaled_mouse_x, scaled_mouse_y])
              @highlighted_rail = [column, row, connection]
              break
            end
          end
        end
      end
    end

    def draw
      scale(scaled_width, scaled_height) do
        drawn_columns.times do |x|
          drawn_rows.times do |y|
            translate(y.odd? ? drawn_tile_size / 2 : 0, 0) do
              rail_size = Math.sqrt(  drawn_tile_size      ** 2 +
                                     (drawn_tile_size / 2) ** 2 ).round
              rail_x = x * drawn_tile_size +
                       drawn_tile_size / 2 -
                       drawn_rail_width / 2
              rail_y = y * drawn_tile_size + drawn_tile_size / 2
              3.times do |connection|
                next if y.zero?             &&  connection == 2
                next if x.zero?             && (connection == 1 || y.even?)
                next if y == drawn_rows - 1 &&  connection == 0

                angle = 30 + 60 * connection
                color = @highlighted_rail == [x, y, connection] ? 0xFFFF2600
                                                                : 0xFFFFFFFF
                @pixel_image.draw_rot(
                  rail_x,
                  rail_y,
                  0,
                  angle,
                  0.5,
                  0.0,
                  drawn_rail_width,
                  angle == 90 ? drawn_tile_size : rail_size,
                  color
                )
              end

              color = @highlighted_hub == [x, y] ? 0xFFFFFC79 : 0xFFCA7200
              @hub_image.draw(
                x * drawn_tile_size + (drawn_tile_size - @hub_image.width) / 2,
                y * drawn_tile_size + (drawn_tile_size - @hub_image.height) / 2,
                1,
                1,
                1,
                color
              )
            end
          end
        end
      end
    end

    def button_down(id)
      if id == Gosu::KbEscape
        exit
      end
    end

    def needs_cursor?
      true
    end

    private

    def drawn_width
      2880
    end

    def drawn_height
      1800
    end

    def drawn_tile_size
      120
    end

    def drawn_rail_width
      2
    end

    def highlightable_rail_width
      20
    end

    def drawn_columns
      15
    end

    def drawn_rows
      15
    end

    def current_width
      1280
    end

    def current_height
      800
    end

    def scaled_width
      current_width.to_f / drawn_width
    end

    def scaled_height
      current_height.to_f / drawn_height
    end
  end
end
