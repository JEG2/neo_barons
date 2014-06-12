module NeoBarons
  class City
    def initialize(name: , small: )
      @name  = name
      @small = small
    end

    attr_reader :name

    def small?
      @small
    end
  end
end
