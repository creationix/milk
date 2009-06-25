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
      haml_file = "#{FIELDS_DIR}/#{name}.haml"
      if File.file?(haml_file)
        ::Haml::Engine.new(File.read(haml_file), :filename => haml_file).render(self)
      else
        "#{self.class} Not Implemented"
      end
    end
    
  end
  
  # This module is a namespace for all the subclasses of Milk::Field
  # Is sets up autoloading for the fields classes
  module Fields

    Dir.glob(Milk::FIELDS_DIR + "/*.rb").each do |c|
      name = c.split('/').last.gsub(/(.*)\.rb/) { $1 }
      class_name = name.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
      path = c.gsub(/(.*)\.rb/) { $1 }
      autoload class_name.to_sym, path
    end
  
  end
  
end

