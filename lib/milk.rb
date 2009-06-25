# Autoload some useful libraries
autoload 'Haml', 'haml'
autoload 'Sass', 'sass'
autoload 'Maruku', 'maruku'
autoload 'YAML', 'yaml'
autoload 'FileUtils', 'fileutils'

# Set up our main namespace with autoloaded parts
module Milk
  VERSION = '0.0.5'

  LIB_DIR = File.dirname(__FILE__)
  BIN_DIR ||= File.absolute_path(File.dirname(__FILE__)+"/../../local/bin")
  TEMPLATE_DIR = File.absolute_path(LIB_DIR+"/../site_template")
  def self.get_milk_root
    c = caller(1).collect { |line| line.split(':').first }
    c = c.select { |line| line !~ /\/gems\// }
    File.absolute_path(File.dirname(c.first))
  end
  MILK_ROOT ||= get_milk_root 
  CONFIG_DIR = MILK_ROOT + "/config"
  
  # Load overrides from config file
  config_file = CONFIG_DIR+"/config.yaml"
  YAML.load(open(CONFIG_DIR+"/config.yaml")).each_pair do |key, value|
    eval("#{key} = #{value.inspect}")
  end if File.file?(config_file)
  
  # Set defaults otherwise
  COMPONENTS_DIR ||= MILK_ROOT + "/design"
  PAGES_DIR ||= MILK_ROOT + "/pages"
  PUBLIC_DIR ||= MILK_ROOT + "/public"
  FIELDS_DIR ||= LIB_DIR + "/milk/fields"
  
  $LOAD_PATH.unshift(LIB_DIR) unless $LOAD_PATH.include?(LIB_DIR)
  autoload :Application, "milk/application"
  autoload :Component, "milk/component"
  autoload :Page, "milk/page"
  autoload :Haxe, "milk/haxe"
  autoload :Field, "milk/field"
  autoload :Fields, "milk/field"
  
end

# Autoload the components of the user space app into the root namespace for easy use
Dir.glob(Milk::COMPONENTS_DIR + "/*.rb").each do |c|
  name = c.split('/').last.gsub(/(.*)\.rb/) { $1 }
  class_name = name.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
  path = c.gsub(/(.*)\.rb/) { $1 }
  autoload class_name.to_sym, path
end

# Include metaid for easy metaclass management
class Object
 # The hidden singleton lurks behind everyone
 def metaclass; class << self; self; end; end
 def meta_eval &blk; metaclass.instance_eval &blk; end

 # Adds methods to a metaclass
 def meta_def name, &blk
   meta_eval { define_method name, &blk }
 end

 # Defines an instance method within a class
 def class_def name, &blk
   class_eval { define_method name, &blk }
 end
end

# Add ability to get constants from a string name.
# WARNING: this is akin to eval for security concerns.
class String
  def constantize
    const = Object
    self.split("::").each do |part|
      const = const.const_get(part)
    end
    const
  end
end


