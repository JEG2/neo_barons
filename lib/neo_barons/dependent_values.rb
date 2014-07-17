require "set"

module NeoBarons
  class DependentValues < BasicObject
    Value = ::Struct.new(:default_generator, :current_value, :dependents)

    def initialize
      @values     = { }
      @dependents = [ ]
    end

    def method_missing(method, *args, &block)
      if method =~ /=\z/ || block
        value_name = method.to_s.sub(/=\z/, "")
        if @values.include?(value_name)
          @values[value_name].dependents.each do |dependent|
            __send__("#{dependent}=", nil)
          end
          @values[value_name].current_value = args.first
        else
          @values[value_name] ||= Value.new(block, args.first, ::Set.new)
        end
      elsif method =~ /\A\w+\z/ && @values.include?(method.to_s)
        value_name = method.to_s

        if @values[value_name].current_value.nil? &&
           @values[value_name].default_generator
          @dependents << value_name
          begin
            @values[value_name].current_value =
              @values[value_name].default_generator.call
          ensure
            @dependents.pop
          end
        end

        if @dependents.last
          @values[value_name].dependents << @dependents.last
        end

        @values[value_name].current_value
      else
        super
      end
    end

    # def method_missing(method, *args, &block)
    #   if method =~ /=\z/ || block
    #     value_name            = method.to_s.sub(/=\z/, "")
    #     @values[value_name] ||= Value.new(block, args.first, ::Set.new)
    #     instance_eval <<-END_RUBY
    #     def #{value_name}=(new_value)
    #       @values[#{value_name.inspect}].dependents.each do |dependent|
    #         __send__(dependent + "=", nil)
    #       end

    #       @values[#{value_name.inspect}].current_value = new_value
    #     end

    #     def #{value_name}
    #       if @values[#{value_name.inspect}].current_value.nil? &&
    #          @values[#{value_name.inspect}].default_generator
    #         @dependents << #{value_name.inspect}
    #         begin
    #           @values[#{value_name.inspect}].current_value =
    #             @values[#{value_name.inspect}].default_generator.call
    #         ensure
    #           @dependents.pop
    #         end
    #       end

    #       if @dependents.last
    #         @values[#{value_name.inspect}].dependents << @dependents.last
    #       end

    #       # ::Kernel.p @values
    #       @values[#{value_name.inspect}].current_value
    #     end
    #     END_RUBY
    #   else
    #     super
    #   end
    # end
  end
end
