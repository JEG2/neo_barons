module NeoBarons
  class Polygon
    def initialize(points)
      @points  = points
      @points << @points.first unless @points.last == @points.first
    end

    attr_reader :points

    def rotate(center, angle)
      center_x, center_y = center
      radians            = degrees_to_radians(angle)
      sin                = Math.sin(radians)
      cos                = Math.cos(radians)
      points.map! { |x, y|
        [ cos * (x - center_x) - sin * (y - center_y) + center_x,
          sin * (x - center_x) + cos * (y - center_y) + center_y ].map(&:round)
      }
    end

    # Point in polygon ray casting algorithm.
    def contains?(point)
      x, y   = point
      inside = false
      points.each_cons(2) do |vertex, other_vertex|
        vertex_x,       vertex_y       = vertex
        other_vertex_x, other_vertex_y = other_vertex
        if ( (vertex_y       <= y && y < other_vertex_y) ||
             (other_vertex_y <= y && y < vertex_y) )     &&
           x < (other_vertex_x - vertex_x) *
               (y              - vertex_y) /
               (other_vertex_y - vertex_y) +
               vertex_x
          inside = !inside
        end
      end
      return inside
    end

    private

    def degrees_to_radians(degrees)
      degrees * Math::PI / 180
    end
  end
end
