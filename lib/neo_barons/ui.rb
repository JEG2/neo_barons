require_relative "highlighter"

module NeoBarons
  class UI < Gosu::Window
    EMPTY_INFRASTRUCTURE_COLOR = 0xFF5E5E5E
    CITY_COLOR                 = 0xFFCA7200
    SETTLEMENT_COLOR           = 0xFF945200
    CARGO_COLOR                = 0xFFFFFFFF
    HIGHLIGHT_COLOR            = 0xFF941100

    def initialize
      @highlighter = Highlighter.new( NeoBarons.map,
                                      NeoBarons.sizes,
                                      NeoBarons.grids[:even_connections],
                                      NeoBarons.grids[:odd_connections],
                                      NeoBarons.grids[:hubs],
                                      NeoBarons.grids[:cargos] )

      super(NeoBarons.sizes.current_width, NeoBarons.sizes.current_height, false)
      self.caption = "Neo Barons"
    end

    attr_reader :highlighter
    private     :highlighter

    def update
      highlighter.locate_mouse( mouse_x / NeoBarons.sizes.scaled_width,
                                mouse_y / NeoBarons.sizes.scaled_height )
    end

    def draw
      scale(NeoBarons.sizes.scaled_width, NeoBarons.sizes.scaled_height) do
        { even: NeoBarons.grids[:even_connections],
          odd:  NeoBarons.grids[:odd_connections] }.each do |grid_name, connection_grid|
          connection_grid.each do |tile|
            # connection_grid.outline_tile( tile.x,
            #                               tile.y,
            #                               NeoBarons.sprites[:pixel],
            #                               EMPTY_INFRASTRUCTURE_COLOR )
            3.times do |connection|
              next if tile.y.zero?    &&
                      connection == 2 &&
                      connection_grid == NeoBarons.grids[:even_connections]
              next if tile.x == NeoBarons.sizes.last_column &&
                      connection == 1             &&
                      connection_grid == NeoBarons.grids[:even_connections]
              next if tile.y == 7     &&
                      connection == 0 &&
                      connection_grid == NeoBarons.grids[:even_connections]
              angle = 30 + 60 * connection
              angle -= 3 if connection == 0
              angle += 3 if connection == 2
              color =
                if highlighter.highlight_connection?(grid_name, tile.x, tile.y, connection)
                  HIGHLIGHT_COLOR
                else
                  EMPTY_INFRASTRUCTURE_COLOR
                end
              NeoBarons.sprites[:pixel].draw_rot(
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

        NeoBarons.grids[:hubs].each do |tile|
          # NeoBarons.grids[:hubs].outline_tile( tile.x,
          #                        tile.y,
          #                        NeoBarons.sprites[:pixel],
          #                        CITY_COLOR )
          cell          = NeoBarons.map[tile.y][tile.x]
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
          NeoBarons.sprites[sprite].draw(
            tile.x_offset + 40,
            tile.y_offset + 40,
            1,
            1,
            1,
            color
          )
          if cell.name
            NeoBarons.sprites.name(cell.name).draw(
              tile.x_offset + 82,
              tile.y_offset + 40,
              1
            )
          end
        end

        NeoBarons.grids[:cargos].each do |tile|
          # NeoBarons.grids[:cargos].outline_tile( tile.x,
          #                          tile.y,
          #                          NeoBarons.sprites[:pixel],
          #                          CARGO_COLOR )
          x, y  = tile.x / 2, tile.y
          index =
            if tile.x.odd?
              1
            elsif x < NeoBarons.sizes.drawn_columns && NeoBarons.map[y][x].drawn_cargos[0]
              0
            elsif x > 0 && NeoBarons.map[y][x - 1].drawn_cargos[2]
              x -= 1
              2
            end
          if index && (cargo = NeoBarons.map[y][x].drawn_cargos[index])
            color =
              if highlighter.highlight_cargo?(x, y, index)
                HIGHLIGHT_COLOR
              else
                CARGO_COLOR
              end
            NeoBarons.sprites.cargo(cargo).draw(
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

    def button_down(id)
      case id
      when Gosu::KbEscape
        exit
      end
    end

    def needs_cursor?
      true
    end
  end
end
