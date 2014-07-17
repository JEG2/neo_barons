require_relative "dependent_values"
require_relative "grid"
require_relative "highlighter"
require_relative "sprite_manager"

module NeoBarons
  class UI < Gosu::Window
    EMPTY_INFRASTRUCTURE_COLOR = 0xFF5E5E5E
    CITY_COLOR                 = 0xFFCA7200
    SETTLEMENT_COLOR           = 0xFF945200
    CARGO_COLOR                = 0xFFFFFFFF
    HIGHLIGHT_COLOR            = 0xFF941100

    def initialize(map)
      @map = map

      @sprites              = SpriteManager.new(self)
      @sizes                = build_sizes
      @even_connection_grid = Grid.new( columns:            sizes.drawn_columns,
                                        rows: (sizes.drawn_rows.to_f / 2).round,
                                        width:                              120,
                                        height:                         120 * 2,
                                        global_row_offset:              120 / 2 - 3 + 120 / 4,
                                       global_column_offset:  -20 )
      @odd_connection_grid = Grid.new( columns:            sizes.drawn_columns - 1,
                                       rows: sizes.drawn_rows - (sizes.drawn_rows.to_f / 2).round,
                                       width:                              120,
                                       height:                         120 * 2,
                                       global_row_offset:                  120 - 3 + 120 / 4,
                                       global_column_offset:               100 )
      @hub_grid            = Grid.new( columns:   sizes.drawn_columns,
                                       rows:         sizes.drawn_rows,
                                       width:                     120,
                                       height:                    120,
                                       global_row_offset:     120 / 4,
                                       odd_row_offset:        120 / 2,
                                       global_column_offset:  120 / 3 )
      @cargo_grid          = Grid.new( columns:   sizes.drawn_columns * 2 + 1,
                                       rows:             sizes.drawn_rows,
                                       width:                     120 / 2,
                                       height:                        120,
                                       odd_row_offset:            120 / 2 )
      @highlighter         = Highlighter.new( map,
                                              sizes,
                                              even_connection_grid,
                                              odd_connection_grid,
                                              hub_grid,
                                              cargo_grid )

      super(sizes.current_width, sizes.current_height, false)
      self.caption = "Neo Barons"
    end

    attr_reader :sizes

    attr_reader :map, :sprites, :highlighter,
                :even_connection_grid, :odd_connection_grid, :hub_grid, :cargo_grid
    private     :map, :sprites, :highlighter,
                :even_connection_grid, :odd_connection_grid, :hub_grid, :cargo_grid

    def update
      highlighter.locate_mouse( mouse_x / sizes.scaled_width,
                                mouse_y / sizes.scaled_height )
    end

    def draw
      scale(sizes.scaled_width, sizes.scaled_height) do
        { even: even_connection_grid,
          odd:  odd_connection_grid }.each do |grid_name, connection_grid|
          connection_grid.each do |tile|
            # connection_grid.outline_tile( tile.x,
            #                               tile.y,
            #                               sprites[:pixel],
            #                               EMPTY_INFRASTRUCTURE_COLOR )
            3.times do |connection|
              next if tile.y.zero?    &&
                      connection == 2 &&
                      connection_grid == even_connection_grid
              next if tile.x == sizes.last_column &&
                      connection == 1             &&
                      connection_grid == even_connection_grid
              next if tile.y == 7     &&
                      connection == 0 &&
                      connection_grid == even_connection_grid
              angle = 30 + 60 * connection
              angle -= 3 if connection == 0
              angle += 3 if connection == 2
              color =
                if highlighter.highlight_connection?(grid_name, tile.x, tile.y, connection)
                  HIGHLIGHT_COLOR
                else
                  EMPTY_INFRASTRUCTURE_COLOR
                end
              sprites[:pixel].draw_rot(
                tile.x_offset + 2,
                tile.y_offset + 120,
                0,
                -angle,
                0.5,
                0.0,
                4,
                angle == 90 ? 120 : Math.sqrt(120 ** 2 + (120 / 2.0).ceil ** 2).ceil,
                color
              )
            end
          end
        end

        hub_grid.each do |tile|
          # hub_grid.outline_tile( tile.x,
          #                        tile.y,
          #                        sprites[:pixel],
          #                        CITY_COLOR )
          cell          = map[tile.y][tile.x]
          color, sprite =
            if cell.is_a?(City)
              if cell.small?
                [SETTLEMENT_COLOR, :settlement]
              else
                [CITY_COLOR, :city]
              end
            else
              [EMPTY_INFRASTRUCTURE_COLOR, :hub]
            end
          color         = HIGHLIGHT_COLOR if highlighter.highlight_hub?( tile.x,
                                                                         tile.y )
          sprites[sprite].draw(
            tile.x_offset + 40,
            tile.y_offset + 40,
            1,
            1,
            1,
            color
          )
          if cell.name
            sprites.name(cell.name).draw(
              tile.x_offset + 82,
              tile.y_offset + 40,
              1
            )
          end
        end

        cargo_grid.each do |tile|
          # cargo_grid.outline_tile( tile.x,
          #                          tile.y,
          #                          sprites[:pixel],
          #                          CARGO_COLOR )
          x, y  = tile.x / 2, tile.y
          index =
            if tile.x.odd?
              1
            elsif x < sizes.drawn_columns && map[y][x].drawn_cargos[0]
              0
            elsif x > 0 && map[y][x - 1].drawn_cargos[2]
              x -= 1
              2
            end
          if index && (cargo = map[y][x].drawn_cargos[index])
            color =
              if highlighter.highlight_cargo?(x, y, index)
                HIGHLIGHT_COLOR
              else
                CARGO_COLOR
              end
            sprites.cargo(cargo).draw(
              tile.x_offset + 15,
              tile.y_offset + (tile.x.odd? ? 10 : 30),
              2,
              1,
              1,
              color
            )
          end
        end
      end
    end

    # def draw
    #   scale(sizes.scaled_width, sizes.scaled_height) do
    #     sizes.drawn_columns.times do |x|
    #       sizes.drawn_rows.times do |y|
    #         translate( sizes.half_cargo_width + (y.odd? ? sizes.half_tile : 0),
    #                    sizes.y_offset ) do
    #           rail_x = x * sizes.drawn_tile +
    #                    sizes.half_tile      -
    #                    sizes.half_rail_width
    #           rail_y = y * sizes.drawn_tile + sizes.half_tile
    #           3.times do |connection|
    #             next if y.zero?             &&  connection == 2
    #             next if x.zero?             && (connection == 1 || y.even?)
    #             next if y == sizes.last_row &&  connection == 0

    #             angle = 30                                  +
    #                     60                     * connection +
    #                     sizes.rail_angle_tweak * (connection - 1)
    #             color =
    #               if highlighter.highlight_connection?(x, y, connection)
    #                 HIGHLIGHT_COLOR
    #               else
    #                 EMPTY_INFRASTRUCTURE_COLOR
    #               end
    #             sprites[:pixel].draw_rot(
    #               rail_x,
    #               rail_y,
    #               0,
    #               angle,
    #               0.5,
    #               0.0,
    #               sizes.drawn_rail_width,
    #               angle == 90 ? sizes.drawn_tile : sizes.angled_rail,
    #               color
    #             )
    #           end

    #           cell          = map[y][x]
    #           color, sprite =
    #             if cell.is_a?(City)
    #               if cell.small?
    #                 [SETTLEMENT_COLOR, :settlement]
    #               else
    #                 [CITY_COLOR, :city]
    #               end
    #             else
    #               [EMPTY_INFRASTRUCTURE_COLOR, :hub]
    #             end
    #           color         = HIGHLIGHT_COLOR if highlighter.highlight_hub?(x, y)
    #           sprites[sprite].draw(
    #             x * sizes.drawn_tile + sizes.hub_x,
    #             y * sizes.drawn_tile + sizes.hub_y,
    #             1,
    #             1,
    #             1,
    #             color
    #           )
    #           if cell.name
    #             sprites.name(cell.name).draw(
    #               x * sizes.drawn_tile + sizes.hub_x_plus_width + 2,
    #               y * sizes.drawn_tile + sizes.hub_y,
    #               1
    #             )
    #           end

    #           cell.drawn_cargos.each_with_index do |cargo, i|
    #             next unless cargo
    #             color =
    #               if highlighter.highlight_cargo?(x, y, i)
    #                 HIGHLIGHT_COLOR
    #               else
    #                 CARGO_COLOR
    #               end
    #             sprites.cargo(cargo).draw(
    #               x * sizes.drawn_tile + sizes.hub_x + sizes.half_tile * (i - 1),
    #               y * sizes.drawn_tile +
    #               sizes.cargo_y        +
    #               sizes.cargo_y_tweak * (i % 2 == 1 ? -1 : 1),
    #               2,
    #               1,
    #               1,
    #               color
    #             )
    #           end
    #         end
    #       end
    #     end
    #   end
    # end

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

    def build_sizes
      sizes = DependentValues.new

      sizes.drawn_width       = 2880
      sizes.drawn_height      = 1800
      sizes.drawn_tile        = 120
      sizes.drawn_rail_width  = 2
      sizes.drawn_columns     = map.first.size
      sizes.drawn_rows        = map.size
      sizes.drawn_name_height = 20

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
      sizes.rail_angle_tweak             { 3 }

      sizes.hub_width         { sprites[:hub].width  }
      sizes.hub_height        { sprites[:hub].height }
      sizes.hub_x_tweak       { -1 }
      sizes.hub_x             {
        (sizes.drawn_tile - sizes.hub_width)  / 2 + sizes.hub_x_tweak
      }
      sizes.hub_y             { (sizes.drawn_tile - sizes.hub_height) / 2 }
      sizes.hub_x_plus_width  { sizes.hub_x + sizes.hub_width     }
      sizes.hub_x_plus_name   { sizes.hub_x + sizes.hub_width + 2 }
      sizes.hub_y_plus_height { sizes.hub_y + sizes.hub_height    }
      sizes.half_hub_width    { sizes.hub_width  / 2 }
      sizes.half_hub_height   { sizes.hub_height / 2 }

      sizes.cargo_y                      { sizes.hub_y - sizes.half_tile }
      sizes.cargo_width                  { sprites.cargo(:bacon).width  }
      sizes.cargo_height                 { sprites.cargo(:bacon).height }
      sizes.half_cargo_width             { sizes.cargo_width  / 2 }
      sizes.half_cargo_height            { sizes.cargo_height / 2 }
      sizes.tile_minus_half_cargo_height {
        sizes.drawn_tile - sizes.cargo_height / 2
      }
      sizes.cargo_y_tweak                { 10 }
      sizes.y_offset                     {
        sizes.half_cargo_height + sizes.cargo_y_tweak
      }

      sizes.last_column { sizes.drawn_columns - 1 }
      sizes.last_row    { sizes.drawn_rows    - 1 }

      sizes
    end
  end
end
