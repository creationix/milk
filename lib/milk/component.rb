
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
    
    def self.requires(*resources)
      class_def :requirements do
        resources
      end
    end

    def self.global_properties(*props)
      globals = props.collect{|name|"@#{name}".to_sym}
      class_def :global_properties do
        globals
      end
    end
    
    def name
      self.class.to_s.rpartition('::').last
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
      raise "Missing '#{method}' method" unless File.file? LIB_DIR+"/fields/#{method}.rb"
      klass = eval("Fields::" + method.to_s.gsub(/(^|_)(.)/) { $2.upcase })
      add_field(klass, *args)
    end
    
    def save_settings
      return unless respond_to? :global_properties
      yaml_file = Milk::DATA_DIR + "/global/#{system_name}.yaml"
      data = {}
      global_properties.each do |name|
        data[name.to_s.sub('@','')] = instance_variable_get(name)
      end
      
      File.open(yaml_file, "w") do |file|
        file.write(YAML.dump(data))
      end
    end
    
    def system_name
      self.class.to_s.class_to_require.rpartition('/').last
    end
    
    def load_settings
      yaml_file = Milk::DATA_DIR + "/global/#{system_name}.yaml"
      if File.file? yaml_file
        YAML.load_file(yaml_file).each_pair do |key, value|
          instance_variable_set("@#{key}".to_sym, value)
        end
      end
    end
    

    def edit(prefix)
      @prefix = prefix
      haml("edit.component")
    end
    
    def view
      haml("components/#{system_name}")
    end
    
    
  end

  module Components
    base = Milk::LIB_DIR + "/components/"
    Dir.glob("#{base}*.rb").each do |path|
      autoload path.sub(base, '').path_to_class.to_sym, path
    end
  end

end

