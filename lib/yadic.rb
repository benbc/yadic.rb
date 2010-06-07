module Yadic
  class Container
    def add name, klass=nil, &initializer
      add_initializer(name, klass, initializer)
    end

    def decorate name, klass=nil, &initializer
      add_initializer(name, klass, initializer) do |initializer|
        existing_init = find_initializer(name)
        lambda { initializer.call.decorating(existing_init.call) }
      end
    end
    
    def [] name
      find_initializer(name).call
    end

    class ObjectNotFoundError < StandardError
      def initialize(name) @name=name end
      def message() "No object named #{@name}." end
    end
    
    private
    def initializers() @initializers ||= {} end

    def find_initializer name
      initializers[name] or raise ObjectNotFoundError.new(name)
    end

    def add_initializer name, klass, initializer, &wrap
      initializer = initializer_from(klass, initializer)
      wrap and initializer = wrap.call(initializer)
      initializers[name] = memoize initializer
    end
    
    def memoize initializer
      value = nil
      lambda { value ||= initializer.call }
    end

    def initializer_from(klass, initializer)
      initializer ? lambda { initializer.call(self) } : lambda { klass.new }
    end
  end

  module Decorator
    attr_reader :wrapped
    def decorating(wrapped)
      @wrapped = wrapped
      self
    end
  end
end
