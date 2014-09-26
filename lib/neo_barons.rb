require "gosu"

require_relative "neo_barons/dependent_values"
require_relative "neo_barons/grid"
require_relative "neo_barons/map_generator"
require_relative "neo_barons/sprite_manager"
require_relative "neo_barons/ui"

module NeoBarons
  module_function

  def play
    ui.show
  end

  def ui
    @ui ||= UI.new
  end

  def map
    @map ||= MapGenerator.new.generate
  end

  def sprites
    @sprites ||= SpriteManager.new
  end

  def sizes
    @sizes ||= begin
      s = DependentValues.new

      # s.drawn_width       = 2880
      # s.drawn_height      = 1800
      # s.drawn_tile        = 120
      # s.drawn_rail_width  = 2
      # s.drawn_columns     = map.first.size
      # s.drawn_rows        = map.size
      # s.drawn_name_height = 20

      # s.highlightable_rail_width = 20

      # s.current_width  = 1280  # FIXME:  calculate from resolution
      # s.current_height = 800   # FIXME:  calculate from resolution

      # s.scaled_width  { s.current_width.to_f  / s.drawn_width  }
      # s.scaled_height { s.current_height.to_f / s.drawn_height }

      # s.half_tile                    { s.drawn_tile       / 2 }
      # s.third_tile                   { s.drawn_tile       / 3 }
      # s.two_thirds_tile              { s.third_tile       * 2 }
      # s.half_rail_width              { s.drawn_rail_width / 2 }
      # s.half_highlightable_rail_diff {
      #   (s.highlightable_rail_width - s.drawn_rail_width) / 2
      # }
      # s.angled_rail                  {
      #   Math.sqrt(s.drawn_tile ** 2 + s.half_tile ** 2).round
      # }
      # s.rail_angle_tweak             { 3 }

      # s.hub_width         { sprites[:hub].width  }
      # s.hub_height        { sprites[:hub].height }
      # s.hub_x_tweak       { -1 }
      # s.hub_x             {
      #   (s.drawn_tile - s.hub_width)  / 2 + s.hub_x_tweak
      # }
      # s.hub_y             { (s.drawn_tile - s.hub_height) / 2 }
      # s.hub_x_plus_width  { s.hub_x + s.hub_width     }
      # s.hub_x_plus_name   { s.hub_x + s.hub_width + 2 }
      # s.hub_y_plus_height { s.hub_y + s.hub_height    }
      # s.half_hub_width    { s.hub_width  / 2 }
      # s.half_hub_height   { s.hub_height / 2 }

      # s.cargo_y                      { s.hub_y - s.half_tile }
      # s.cargo_width                  { sprites.cargo(:bacon).width  }
      # s.cargo_height                 { sprites.cargo(:bacon).height }
      # s.half_cargo_width             { s.cargo_width  / 2 }
      # s.half_cargo_height            { s.cargo_height / 2 }
      # s.tile_minus_half_cargo_height {
      #   s.drawn_tile - s.cargo_height / 2
      # }
      # s.cargo_y_tweak                { 10 }
      # s.y_offset                     {
      #   s.half_cargo_height + s.cargo_y_tweak
      # }

      # s.last_column { s.drawn_columns - 1 }
      # s.last_row    { s.drawn_rows    - 1 }

      s
    end
  end

  def grids
    @grids ||= {
      even_connections: Grid.new(
        columns:            sizes.drawn_columns,
        rows: (sizes.drawn_rows.to_f / 2).round,
        width:                              120,
        height:                         120 * 2,
        global_row_offset:              120 / 2 - 3 + 120 / 4,
        global_column_offset:  -20
      ),
      odd_connections: Grid.new(
        columns:            sizes.drawn_columns - 1,
        rows: sizes.drawn_rows - (sizes.drawn_rows.to_f / 2).round,
        width:                              120,
        height:                         120 * 2,
        global_row_offset:                  120 - 3 + 120 / 4,
        global_column_offset:               100
      ),
      hubs: Grid.new(
        columns:   sizes.drawn_columns,
        rows:         sizes.drawn_rows,
        width:                     120,
        height:                    120,
        global_row_offset:     120 / 4,
        odd_row_offset:        120 / 2,
        global_column_offset:  120 / 3
      ),
      cargos: Grid.new(
        columns:   sizes.drawn_columns * 2 + 1,
        rows:             sizes.drawn_rows,
        width:                     120 / 2,
        height:                        120,
        odd_row_offset:            120 / 2
      )
    }
  end
end
