module Milk
  class Component
  
    @@local_flag = {}
    
    attr_accessor :parent
    @parent = nil

    
    # Don't store global properties or backreferences to the parent
    def to_yaml_properties
      (if respond_to? :global_properties
        instance_variables.reject { |name| global_properties.member?(name) }
      else
        instance_variables
      end).reject { |name| name == :@parent }
    end
    
    def app
      page.app
    end

    def page
      if @parent.class == Milk::Page
        @parent
      else
        @parent.page
      end
    end
    
    def self.local_properties(*props)
    end

    def self.global_properties(*props)
      globals = props.collect{|name|"@#{name}".to_sym}
      class_def :global_properties do
        globals
      end
    end
    
    def name
      self.class.to_s
    end

    # All Components start out with default of no fields    
    def self.fields
      []
    end
    
    # Assume no defaults
    def self.defaults
      {}
    end

    # Metaclass black magic to simulate appending items to a list
    # This works by getting the old result of the fields class method
    # and stores it in a closure, and then redefines the method, but with
    # a new item appended.
    def self.add_field(klass, field, label, options={})
    
      # Merge in assumes options
      options[:field] = field
      options[:label] = label
      
      # Fill in blanks with defaults
      defaults.each do |k, v|
        options[k] ||= v
      end
      
      field = klass.new(options)
      
      newfields = self.fields + [field]
      meta_def("fields") do
        newfields
      end
    end
    
    def self.method_missing(method, *args)
      raise "Missing '#{method}' method" unless File.file? FIELDS_DIR+"/#{method}.rb"
      klass = eval("Fields::" + method.to_s.gsub(/(^|_)(.)/) { $2.upcase })
      add_field(klass, *args)
    end
    
    def save_settings
      return unless respond_to? :global_properties
      yaml_file = Milk::CONFIG_DIR + "/#{system_name}.yaml"
      data = {}
      global_properties.each do |name|
        data[name.to_s.sub('@','')] = instance_variable_get(name)
      end
      
      File.open(yaml_file, "w") do |file|
        file.write(YAML.dump(data))
      end
    end
    
    def system_name
      self.class.to_s.gsub(/([a-z])([A-Z])/) { "#{$1}_#{$2}" }.downcase
    end
    
    def load_settings
      yaml_file = Milk::CONFIG_DIR + "/#{system_name}.yaml"
      if File.file? yaml_file
        YAML.load_file(yaml_file).each_pair do |key, value|
          instance_variable_set("@#{key}".to_sym, value)
        end
      end
    end
    
    def haml(filename, context=self, extras={})
      if block_given?
        Page.haml(filename, context, extras) { yield }
      else
        Page.haml(filename, context, extras)
      end
    end

    def partial(filename, vars, extras={})
      obj = self.dup
      vars.each do |key, value|
        obj.instance_variable_set("@#{key}", value)
      end
      haml(filename, obj, extras)
    end


    def edit(prefix)
      @prefix = prefix
      haml_file = FIELDS_DIR + "/component.haml"
      ::Haml::Engine.new(File.read(haml_file), :filename => haml_file).render(self)
    end
    
    def view
      haml_file = Milk::COMPONENTS_DIR + "/" + system_name + ".haml"
      raise "Missing template \"" + haml_file + "\"" unless File.file? haml_file
      ::Haml::Engine.new(File.read(haml_file), :filename => haml_file).render(self)
    end
    
  end
end


