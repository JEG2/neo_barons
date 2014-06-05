module NeoBarons
  class Window < Gosu::Window
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
    end

    def update
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
      else
        @highlighted_hub = nil
      end

      # unless @highlighted_hub
      #   clickable_rail_width = drawn_rail_width * 2
      #   clickable_rail_start = (drawn_tile_size - clickable_rail_width) / 2
      #   if column < drawn_columns &&
      #      y_offset.between?( clickable_rail_start,
      #                         clickable_rail_start + clickable_rail_width )
      #     @highlighted_rail = [column, row]
      #   end
      # end
    end

    def draw
      scale(scaled_width, scaled_height) do
        drawn_columns.times do |x|
          drawn_rows.times do |y|
            translate(y.odd? ? drawn_tile_size / 2 : 0, 0) do
              rail_size = Math.sqrt(  drawn_tile_size      ** 2 +
                                     (drawn_tile_size / 2) ** 2 ).round
              rail_x = x * drawn_tile_size + drawn_tile_size / 2
              rail_y = y * drawn_tile_size + drawn_tile_size / 2
              3.times do |connection|
                next if y.zero?             &&  connection == 2
                next if x.zero?             && (connection == 1 || y.even?)
                next if y == drawn_rows - 1 &&  connection == 0

                angle = 30 + 60 * connection
                color = @highlighted_rail == [x, y] ? 0xFFFF2600 : 0xFFFFFFFF
                rotate(angle, rail_x, rail_y) do
                  @pixel_image.draw(
                    rail_x,
                    rail_y,
                    0,
                    drawn_rail_width,
                    angle == 90 ? drawn_tile_size : rail_size,
                    color
                  )
                end
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
