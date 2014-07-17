require_relative "dependent_values"

module NeoBarons
  class Grid
    class OutOfGridError < RuntimeError; end

    include Enumerable

    def initialize( columns:               ,
                    rows:                  ,
                    width:                 ,
                    height:                ,
                    global_row_offset:    0,
                    even_row_offset:      0,
                    odd_row_offset:       0,
                    global_column_offset: 0,
                    even_column_offset:   0,
                    odd_column_offset:    0 )
      @sizes = build_sizes( columns,
                            rows,
                            width,
                            height,
                            global_row_offset:    global_row_offset,
                            even_row_offset:      even_row_offset,
                            odd_row_offset:       odd_row_offset,
                            global_column_offset: global_column_offset,
                            even_column_offset:   even_column_offset,
                            odd_column_offset:    odd_column_offset )
    end

    attr_reader :sizes
    private     :sizes

    def [](x, y)
      fail OutOfGridError unless x.between?(0, sizes.last_column)
      fail OutOfGridError unless y.between?(0, sizes.last_row)

      sizes.x       = x
      sizes.y       = y
      sizes.mouse_x = nil
      sizes.mouse_y = nil

      sizes
    end

    def from_mouse(mouse_x, mouse_y)
      x, _, y, _ = mouse_coordinates(mouse_x, mouse_y)
      y_offset   =
        if x.even? then sizes.even_column_offset
        else            sizes.odd_column_offset
        end
      x_offset   =
        if y.even? then sizes.even_row_offset
        else            sizes.odd_row_offset
        end

      x, local_x, y, local_y =
        mouse_coordinates(mouse_x, mouse_y, x_offset, y_offset)
      tile                   = self[x, y]
      tile.mouse_x           = local_x
      tile.mouse_y           = local_y
      tile
    rescue OutOfGridError
      nil
    end

    def each
      sizes.rows.times do |y|
        sizes.columns.times do |x|
          yield(self[x, y])
        end
      end
    end

    def outline_tile(x, y, pixel, color)
      tile = self[x, y]
      pixel.draw( tile.x_offset,
                  tile.y_offset,
                  0,
                  tile.width,
                  3,
                  color )
      pixel.draw( tile.last_x,
                  tile.y_offset,
                  0,
                  3,
                  tile.height,
                  color )
      pixel.draw( tile.x_offset,
                  tile.last_y,
                  0,
                  tile.width,
                  3,
                  color )
      pixel.draw( tile.x_offset,
                  tile.y_offset,
                  0,
                  3,
                  tile.height,
                  color )
    end

    private

    def build_sizes(columns, rows, width, height, offsets)
      sizes = DependentValues.new

      sizes.columns              = columns
      sizes.rows                 = rows
      sizes.width                = width
      sizes.height               = height
      sizes.global_row_offset    = offsets.fetch(:global_row_offset)
      sizes.even_row_offset      = offsets.fetch(:even_row_offset)
      sizes.odd_row_offset       = offsets.fetch(:odd_row_offset)
      sizes.global_column_offset = offsets.fetch(:global_column_offset)
      sizes.even_column_offset   = offsets.fetch(:even_column_offset)
      sizes.odd_column_offset    = offsets.fetch(:odd_column_offset)

      sizes.last_column { sizes.columns - 1 }
      sizes.last_row    { sizes.rows    - 1 }

      sizes.x_offset {
        sizes.x * sizes.width +
        sizes.global_row_offset +
        (sizes.y.even? ? sizes.even_row_offset : sizes.odd_row_offset)
      }
      sizes.last_x {
        sizes.x_offset + (sizes.width - 1)
      }
      sizes.y_offset {
        sizes.y * sizes.height +
        sizes.global_column_offset  +
        (sizes.x.even? ? sizes.even_column_offset : sizes.odd_column_offset)
      }
      sizes.last_y {
        sizes.y_offset + (sizes.height - 1)
      }

      sizes
    end

    def mouse_coordinates(mouse_x, mouse_y, x_offest = 0, y_offset = 0)
      [
        (mouse_x - sizes.global_row_offset    - x_offest).divmod(sizes.width),
        (mouse_y - sizes.global_column_offset - y_offset).divmod(sizes.height)
      ].flatten
    end
  end
end
