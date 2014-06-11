require "gosu"

require_relative "neo_barons/map_generator"
require_relative "neo_barons/ui"

module NeoBarons
  module_function

  def play
    map = MapGenerator.new.generate
    UI.new(map).show
  end
end
