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
      @cargo_names  = load_cargos(@width * @height / 10)
    end

    attr_reader :width, :height, :cities, :small_cities,
                :city_names, :cargo_names
    private     :width, :height, :cities, :small_cities,
                :city_names, :cargo_names

    def generate
      Array.new(height) {
        last_was_big_city = false
        Array.new(width) {
          if rand < cities
            small             = last_was_big_city || rand < small_cities
            last_was_big_city = !small
            City.new( name:   city_names.shift,
                      small:  small,
                      cargos: choose_cargos(small) )
          else
            last_was_big_city = false
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

    def load_cargos(max)
      names = [ ]
      Dir.glob( File.join( __dir__,
                           *%w[.. .. data sprites *_cargo.png] ) ) do |name|
        names << File.basename(name, ".png").sub(/_cargo\z/, "")
      end
      names.shuffle.first(max)
    end

    def choose_cargos(small_city)
      cargo_names.sample(rand(small_city ? 0..1 : 1..3))
    end
  end
end
