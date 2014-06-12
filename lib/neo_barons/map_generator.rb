require "set"

require_relative "city"
require_relative "hub"

module NeoBarons
  class MapGenerator
    def initialize(width: 15, height: 15, cities: 0.3, small_cities: 0.6)
      @width        = width
      @height       = height
      @cities       = cities
      @small_cities = small_cities
      @city_names   = load_names(@width * @height)
    end

    attr_reader :width, :height, :cities, :small_cities, :city_names
    private     :width, :height, :cities, :small_cities, :city_names

    def generate
      Array.new(height) {
        Array.new(width) {
          if rand < cities
            City.new(name: city_names.shift, small: rand < small_cities)
          else
            Hub.new
          end
        }
      }
    end

    private

    def load_names(max_cities)
      names = Set.new

      File.foreach( File.join( __dir__,
                               *%w[.. .. data names cities.txt] ) ) do |name|
        names << name.strip
      end

      while names.size < max_cities
        names << "#{('A'..'Z').to_a.shuffle.first(2).join}-#{rand(100..999)}"
      end

      names.to_a.shuffle
    end
  end
end
