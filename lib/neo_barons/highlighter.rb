require_relative "polygon"

module NeoBarons
  class Highlighter
    def initialize(map, sizes, even_connection_grid, odd_connection_grid, hub_grid, cargo_grid)
      @map         = map
      @sizes       = sizes
      @even_connection_grid = even_connection_grid
      @odd_connection_grid = odd_connection_grid
      @hub_grid = hub_grid
      @cargo_grid = cargo_grid

      reset_highlight
    end

    attr_reader :map, :sizes, :pointing_at, :even_connection_grid, :odd_connection_grid, :hub_grid, :cargo_grid
    private     :map, :sizes, :pointing_at, :even_connection_grid, :odd_connection_grid, :hub_grid, :cargo_grid

    def locate_mouse(x, y)
      reset_highlight

      locate_in_hub(x, y)   ||
      locate_in_cargo(x, y) ||
      locate_in_connection(x, y)
    end

    def highlight_connection?(even_or_odd, x, y, connection)
      pointing_at[0]     == :connection &&
      pointing_at[1..-1] == [even_or_odd, x, y, connection]
    end

    def highlight_hub?(x, y)
      pointing_at[0] == :hub && pointing_at[1..-1] == [x, y]
    end

    def highlight_cargo?(x, y, cargo)
      pointing_at[0] == :cargo && pointing_at[1..-1] == [x, y, cargo]
    end

    private

    def reset_highlight
      @pointing_at = [:unknown]
    end

    def locate_in_hub(x, y)
      if (tile = hub_grid.from_mouse(x, y)) &&
         tile.mouse_x.between?(40, 80) && tile.mouse_y.between?(40, 80)
        @pointing_at = [:hub, tile.x, tile.y]
      end

      pointing_at.first == :hub
    end

    def locate_in_cargo(x, y)
      if (tile = cargo_grid.from_mouse(x, y))
        x, y  = [tile.x / 2, tile.y]
        index =
          if tile.x.odd?
            1
          elsif x < sizes.drawn_columns && map[y][x].drawn_cargos[0]
            0
          elsif x > 0 && map[y][x - 1].drawn_cargos[2]
            x -= 1
            2
          end
        if index && map[y][x].drawn_cargos[index]
          y_offset = tile.x.odd? ? 10 : 30
          if tile.mouse_x.between?(15, 45) &&
             tile.mouse_y.between?(y_offset, y_offset + 30)
            @pointing_at = [:cargo, x, y, index]
          end
        end
      end

      pointing_at.first == :cargo
    end

    def locate_in_connection(x, y)
      catch(:done) do
        { even: even_connection_grid,
          odd:  odd_connection_grid }.each do |grid_name, connection_grid|
          tile = connection_grid.from_mouse(x, y)
          if tile
            rail_x = 2
            rail_y = 120
            3.times do |connection|
              angle                   = 30 + 60 * connection
              angle -= 3 if connection == 0
              angle += 3 if connection == 2
              highlight_x             = rail_x - sizes.half_highlightable_rail_diff
              highlight_y             = rail_y + sizes.half_hub_height
              highlight_x_plus_width  = highlight_x +
                                        sizes.highlightable_rail_width
              highlight_y_plus_height = highlight_y                         +
                                        ( angle == 90 ? sizes.drawn_tile
                                                      : sizes.angled_rail ) -
                                        sizes.hub_width
              highlight_area = Polygon.new( [
                [highlight_x,            highlight_y],
                [highlight_x_plus_width, highlight_y],
                [highlight_x_plus_width, highlight_y_plus_height],
                [highlight_x,            highlight_y_plus_height]
              ] )
              highlight_area.rotate([rail_x + sizes.half_rail_width, rail_y], -angle)
              if highlight_area.contains?( [ tile.mouse_x,
                                             tile.mouse_y ] )
                @pointing_at = [ :connection,
                                 grid_name,
                                 tile.x,
                                 tile.y,
                                 connection ]
                throw :done
              end
            end
          end
        end
      end

      pointing_at == :connection
    end
  end
end
