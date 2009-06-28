module Milk
  
  # A field is a data type for part of a component.  This way components can be
  # quickly built without coding any logic.  The fields take care of the heavy
  # work.
  class Field
    
    attr_reader :field
    
    # Store the field configurations
    def initialize(props)
      props.each do |key, value|
        self.instance_variable_set('@' + key.to_s, value)
      end
    end
    
    # This is the name shown to the user for the field.
    def name
      @label || self.class.to_s.rpartition('::').last
    end

    def form_field
      @prefix
    end
    
    def value
      @component.instance_variable_get('@' + @field.to_s)
    end
    
    # This is called to render the html for a field's form
    def render(component, prefix)
      @component = component
      @prefix = prefix
      
      name = self.class.to_s.rpartition('::').last.gsub(/([a-z])([A-Z])/) { "#{$1}_#{$2}" }.downcase
      haml("fields/#{name}")
    end

  
  end

  module Fields
    base = Milk::LIB_DIR + "/fields/"
    Dir.glob("#{base}*.rb").each do |path|
      autoload path.sub(base, '').path_to_class.to_sym, path
    end
  end
end

