module NeoBarons
  class Hub
    def name
      nil
    end

    def cargos
      [ ]
    end
    alias_method :drawn_cargos, :cargos
  end
end
