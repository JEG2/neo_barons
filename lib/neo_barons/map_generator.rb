require_relative "city"
require_relative "hub"

module NeoBarons
  class MapGenerator
    def initialize(width: 15, height: 15, cities: 0.3, small_cities: 0.6)
      @width        = width
      @height       = height
      @cities       = cities
      @small_cities = small_cities
    end

    attr_reader :width, :height, :cities, :small_cities
    private     :width, :height, :cities, :small_cities

    def generate
      Array.new(height) {
        Array.new(width) {
          if rand < cities
            City.new(small: rand < small_cities)
          else
            Hub.new
          end
        }
      }
    end
  end
end
