
module Logbert

  class Level
    attr_reader :name, :value
    
    def initialize(name, value)
      @name  = name
      @value = value
    end
    
    def to_s
      @name.to_s
    end
  end

  # This class doubles as a mixin.  Bazinga!
  class LevelManager < Module
    
    def initialize
      @name_to_level  = {}
      @value_to_level = {}

      @quick_lookup   = {}
    end
    
    def names
      @name_to_level.keys
    end
    
    def values
      @value_to_level.keys
    end
    
    

    
    def define_level(name, value)
      raise ArgumentError, "The Level's name must be a Symbol" unless name.instance_of? Symbol
      raise ArgumentError, "The Level's value must be an Integer" unless value.is_a? Integer
      
      # TODO: Verify that the name/value are not already taken
      raise KeyError, "A Level with that name is already defined: #{name}" if @name_to_level.has_key? name
      raise KeyError, "A Level with that value is already defined: #{value}" if @value_to_level.has_key? value
      
      level = Level.new(name, value)

      @name_to_level[name]   = level
      @value_to_level[value] = level
      @quick_lookup[name] = @quick_lookup[value] = @quick_lookup[level] = level
      
      self.create_logging_method(name)
    end
    
    def levels
      @name_to_level.values
    end
    
    
    def [](x)
      @quick_lookup[x] or begin
        if x.is_a? Integer
          # Return either the pre-defined level, or produce a virtual level.
          level = @value_to_level[x] || Logbert::Level.new("LEVEL_#{x}".to_sym, x)
          return level
        elsif x.is_a? String
          level = @name_to_level[x.to_sym]
          return level if level
        end
        
        raise KeyError, "No Level could be found for input: #{x}"
      end
    end


    protected
    
    def create_logging_method(level_name)
      define_method level_name do |content = nil, &block|
        self.log(level_name, content, &block)
      end
    end


  end
  
  

  Levels = {
    off:    0,
    debug: 10,
    info:  20,
    warn:  30,
    error: 40,
    fatal: 50,
    all:   100
  }

  
  
  module LevelsMixin
    
    Logbert::Levels.each do |level_name, level_value|
      define_method level_name do |content = nil, &block|
        self.log(level_value, content, &block)
      end
    end
    
  end

end
