# Autoload some useful libraries
autoload 'Haml', 'haml'
autoload 'Sass', 'sass'
autoload 'Maruku', 'maruku'
autoload 'YAML', 'yaml'
autoload 'FileUtils', 'fileutils'

# Set up our main namespace with autoloaded parts
module Milk

  def self.get_milk_root
    c = caller(1).collect { |line| line.split(':').first }
    c = c.select { |line| line !~ /\/gems\// }
    File.absolute_path(File.dirname(c.first))
  end

  # Setup some nice constants
  MILK_DIR = File.dirname(__FILE__)
  SITE_DIR ||= get_milk_root 
  VERSION = open(MILK_DIR+"/../VERSION").read

  # All these can be overidden by the bootstrap.rb file
  DATA_DIR ||= SITE_DIR + "/data"
  LIB_DIR ||= SITE_DIR + "/lib"
  TEMPLATE_DIR ||= SITE_DIR + "/templates"
  PUBLIC_DIR ||= SITE_DIR + "/public"
  
  $LOAD_PATH.unshift(MILK_DIR) unless $LOAD_PATH.include?(MILK_DIR)
  $LOAD_PATH.unshift(LIB_DIR) unless $LOAD_PATH.include?(LIB_DIR)
  autoload :Application, "milk/application"
  autoload :Component, "milk/component"
  autoload :Components, "milk/component"
  autoload :Page, "milk/page"
  autoload :Field, "milk/field"
  autoload :Fields, "milk/field"

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

  # Better integration of haml with our objects
  def haml(path, extras={})
    filename = "#{Milk::TEMPLATE_DIR}/#{path}.haml"
    if block_given?
      ::Haml::Engine.new(File.read(filename), :filename => filename).render(self, extras) do
        yield
      end
    else
      ::Haml::Engine.new(File.read(filename), :filename => filename).render(self, extras)
    end
  end

end

class String
  # Add ability to get constants from a string name.
  # WARNING: this is akin to eval for security concerns.
  def constantize
    const = Object
    self.split("::").each do |part|
      const = const.const_get(part)
    end
    const
  end
  
  # Useful for converting between filepaths, require paths, and class names
  def path_to_require
    name = self.rpartition('.').first
    $LOAD_PATH.each do |lib|
      name.sub!(lib+"/", '')
    end
    name
  end
  def require_to_path
    Milk::LIB_DIR + "/" + self + ".rb"
  end
  def require_to_class
    self.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
  end
  def class_to_require
    self.gsub(/([a-z])([A-Z])/) { "#{$1}_#{$2}" }.downcase.gsub('::', '/')
  end
  def path_to_class
    self.path_to_require.require_to_class
  end
  def class_to_path
    self.class_to_require.require_to_path
  end

end


