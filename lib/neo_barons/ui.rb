require_relative "polygon"
require_relative "dependent_values"

module NeoBarons
  class UI < Gosu::Window
    def initialize(map)
      @map = map

      @sprites = build_sprite_manager
      @sizes   = build_sizes

      super(sizes.current_width, sizes.current_height, false)
      self.caption = "Neo Barons"

      reset_highlight
    end

    attr_reader :map, :sprites, :sizes
    private     :map, :sprites, :sizes

    def update
      reset_highlight

      scaled_mouse_x   = mouse_x / sizes.scaled_width
      scaled_mouse_y   = mouse_y / sizes.scaled_height
      row,    y_offset = scaled_mouse_y.divmod(sizes.drawn_tile)
      scaled_mouse_x   = [0, scaled_mouse_x - sizes.half_tile].max if row.odd?
      column, x_offset = scaled_mouse_x.divmod(sizes.drawn_tile)
      if column < sizes.drawn_columns &&
         x_offset.between?(sizes.hub_x, sizes.hub_x_plus_width) &&
         y_offset.between?(sizes.hub_y, sizes.hub_y_plus_height)
        @highlighted_hub = [column, row]
      end

      if !@highlighted_hub
        if x_offset > sizes.half_tile
          fix_row_offsets = ->(row_offset) {
            row    += row_offset
            column += 1 if row.even?
            if row.odd?
              scaled_mouse_x = [0, scaled_mouse_x - sizes.half_tile].max
            else
              scaled_mouse_x = mouse_x / sizes.scaled_width
            end
          }
          case y_offset
          when 0...sizes.third_tile
            fix_row_offsets.(-1)
          when sizes.third_tile..sizes.two_thirds_tile
            column += 1
          else
            fix_row_offsets.(1)
          end
        end
        if column < sizes.drawn_columns && row.between?(0, sizes.drawn_rows)
          rail_x = column * sizes.drawn_tile +
                   sizes.half_tile           -
                   sizes.half_rail_width
          rail_y = row * sizes.drawn_tile + sizes.half_tile
          3.times do |connection|
            angle                   = 30 + 60 * connection
            highlight_x             = rail_x - sizes.half_highlightable_rail_diff
            highlight_y             = rail_y + sizes.half_hub_height
            highlight_x_plus_width  = highlight_x +
                                      sizes.highlightable_rail_width
            highlight_y_plus_height = highlight_y                         +
                                      ( angle == 90 ? sizes.drawn_tile
                                                    : sizes.angled_rail ) -
                                      sprites[:hub].width
            highlight_area = Polygon.new( [
              [highlight_x,            highlight_y],
              [highlight_x_plus_width, highlight_y],
              [highlight_x_plus_width, highlight_y_plus_height],
              [highlight_x,            highlight_y_plus_height]
            ] )
            highlight_area.rotate( [rail_x + sizes.half_rail_width, rail_y],
                                   angle )
            if highlight_area.contains?([scaled_mouse_x, scaled_mouse_y])
              @highlighted_rail = [column, row, connection]
              break
            end
          end
        end
      end
    end

    def draw
      scale(sizes.scaled_width, sizes.scaled_height) do
        sizes.drawn_columns.times do |x|
          sizes.drawn_rows.times do |y|
            translate(y.odd? ? sizes.drawn_tile / 2 : 0, 0) do
              rail_x = x * sizes.drawn_tile +
                       sizes.half_tile      -
                       sizes.half_rail_width
              rail_y = y * sizes.drawn_tile + sizes.half_tile
              3.times do |connection|
                next if y.zero?             &&  connection == 2
                next if x.zero?             && (connection == 1 || y.even?)
                next if y == sizes.last_row &&  connection == 0

                angle = 30 + 60 * connection
                color = @highlighted_rail == [x, y, connection] ? 0xFFFF2600
                                                                : 0xFFFFFFFF
                sprites[:pixel].draw_rot(
                  rail_x,
                  rail_y,
                  0,
                  angle,
                  0.5,
                  0.0,
                  sizes.drawn_rail_width,
                  angle == 90 ? sizes.drawn_tile : sizes.angled_rail,
                  color
                )
              end

              color = @highlighted_hub == [x, y] ? 0xFFFFFC79 : 0xFFCA7200
              sprite =
                if map[y][x].is_a?(City)
                  map[y][x].small? ? :small_city : :city
                else
                  :hub
                end
              sprites[sprite].draw(
                x * sizes.drawn_tile + sizes.hub_x,
                y * sizes.drawn_tile + sizes.hub_y,
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
      case id
      when Gosu::KbEscape
        exit
      end
    end

    def needs_cursor?
      true
    end

    private

    def build_sprite_manager
      Hash.new { |all, key|
        all[key] = Gosu::Image.new(
          self,
          File.join(File.dirname(__FILE__), *%W[.. .. data sprites #{key}.png]),
          key == :pixel
        )
      }
    end

    def build_sizes
      sizes = DependentValues.new

      sizes.drawn_width      = 2880
      sizes.drawn_height     = 1800
      sizes.drawn_tile       = 120
      sizes.drawn_rail_width = 2
      sizes.drawn_columns    = map.first.size
      sizes.drawn_rows       = map.size

      sizes.highlightable_rail_width = 20

      sizes.current_width  = 1280  # FIXME:  calculate from resolution
      sizes.current_height = 800   # FIXME:  calculate from resolution

      sizes.scaled_width  { sizes.current_width.to_f  / sizes.drawn_width  }
      sizes.scaled_height { sizes.current_height.to_f / sizes.drawn_height }

      sizes.half_tile                    { sizes.drawn_tile       / 2 }
      sizes.third_tile                   { sizes.drawn_tile       / 3 }
      sizes.two_thirds_tile              { sizes.third_tile       * 2 }
      sizes.half_rail_width              { sizes.drawn_rail_width / 2 }
      sizes.half_highlightable_rail_diff {
        (sizes.highlightable_rail_width - sizes.drawn_rail_width) / 2
      }
      sizes.angled_rail                  {
        Math.sqrt(sizes.drawn_tile ** 2 + sizes.half_tile ** 2).round
      }

      sizes.hub_x             { (sizes.drawn_tile - sprites[:hub].width)  / 2 }
      sizes.hub_y             { (sizes.drawn_tile - sprites[:hub].height) / 2 }
      sizes.hub_x_plus_width  { sizes.hub_x + sprites[:hub].width  }
      sizes.hub_y_plus_height { sizes.hub_y + sprites[:hub].height }
      sizes.half_hub_height   { sprites[:hub].height / 2}

      sizes.last_row { sizes.drawn_rows - 1 }

      sizes
    end

    def reset_highlight
      @highlighted_hub  = nil
      @highlighted_rail = nil
    end
  end
end
