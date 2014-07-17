module NeoBarons
  class City
    def initialize(name: , small: , cargos: )
      @name   = name
      @small  = small
      @cargos = cargos
    end

    attr_reader :name, :cargos

    def small?
      @small
    end

    def drawn_cargos
      case cargos.size
      when 0 then [nil, nil, nil]
      when 1 then [nil, cargos.first, nil]
      when 2 then [cargos.first, nil, cargos.last]
      when 3 then cargos
      end
    end
  end
end
