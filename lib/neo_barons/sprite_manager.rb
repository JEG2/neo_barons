require "forwardable"

module NeoBarons
  class SpriteManager
    extend Forwardable

    def initialize(window)
      @sprites = Hash.new { |sprites, key|
        sprites[key] = Gosu::Image.new(
          window,
          File.join(__dir__, *%W[.. .. data sprites #{key}.png]),
          key == :pixel
        )
      }
      @names   = Hash.new { |images, name|
        images[name] = Gosu::Image.from_text(
          window,
          name,
          Gosu.default_font_name,
          window.sizes.drawn_name_height
        )
      }
    end

    def_delegator :@sprites, :[]
    def_delegator :@names,   :[], :name

    def cargo(name)
      self["#{name}_cargo".to_sym]
    end
  end
end
