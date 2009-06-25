module Milk
  class Page
    
    attr_reader :components
    attr_reader :title
    attr_reader :description
    attr_reader :pagename
    attr_accessor :parent
    @parent = nil
    
    PATH_TO_NAME_REGEXP = Regexp.new("#{Milk::PAGES_DIR}\/(.*)\.yaml")
  
    def self.each_page
      Dir.glob(Milk::PAGES_DIR + "/**/*.yaml").each do |yaml_file|
        p = load_file(yaml_file)
        Milk::Application.join_tree(p, nil)
        yield p
      end
    end
    
    def self.load_file(yaml_file, pagename=nil)
      pagename ||= PATH_TO_NAME_REGEXP.match(yaml_file)[1]
      page = YAML.load_file(yaml_file)
      page.instance_variable_set('@pagename', pagename)
      page.load_settings
      page
    end
    
    def self.find(pagename)
      yaml_file = Milk::PAGES_DIR + "/" + pagename + ".yaml"
      raise PageNotFoundError unless File.readable? yaml_file
      load_file(yaml_file, pagename)
    end

    def self.haml(filename, context, extras)
      if block_given?
        ::Haml::Engine.new(File.read(filename), :filename => filename).render(context, extras) do
          yield
        end
      else
        ::Haml::Engine.new(File.read(filename), :filename => filename).render(context, extras)
      end
    end
    
    def haml(filename, context=self, extras={})
      if block_given?
        Page.haml(filename, context, extras) { yield }
      else
        Page.haml(filename, context, extras)
      end
    end
    
    def to_yaml_properties
      [:@components, :@title, :@keywords, :@description]
    end
    
    def app
      @parent
    end
    
    def save
      save_settings
      yaml_file = Milk::PAGES_DIR + "/" + @pagename + ".yaml"
      data = YAML.dump(self)
      File.open(yaml_file, "w") do |file|
        file.write(data)
      end
      data
    end
    
    def self.json_unserialize(data, pagename=nil)  
      class_name = data.delete('class')
      obj = class_name.constantize.allocate
      data.each do |key, value|
        if value.class == Array
          value.collect! { |item| json_unserialize(item) }
        end
        obj.instance_variable_set("@#{key}", value)
      end
      obj.instance_variable_set("@pagename", pagename) if obj.class == Milk::Page
      obj
    end
    
    def load_settings
      @components.each do |component|
        component.load_settings
      end
    end

    def save_settings
      @components.each do |component|
        component.save_settings
      end
    end

    def edit
      haml(FIELDS_DIR + "/xhtml.haml", self)
    end
    
    def preview
      haml(Milk::COMPONENTS_DIR + "/page.haml", self) do 
        (@components.collect do |component|
          component.view
        end).join("")
      end
    end
    
    def view
      haml(Milk::COMPONENTS_DIR + "/xhtml.haml", self) do 
        preview
      end
    end
    
    def link_to
      if @pagename == "Home"
        "/"
      else
        "/#{@pagename}"
      end
    end
    
    def link_to?(url)
      (@pagename == "Home" && url == '/') || url == "/#{@pagename}"
    end
    
    def save_to_cache(html=nil)
      html ||= view
      folder =  Milk::PUBLIC_DIR + "/cache/" + @pagename
      cache_file = folder + "/index.html"
      # Make the folder if it doesn't exist
      FileUtils.mkdir_p folder
      open(cache_file, "w") { |file| file.write html }
    end
    
  end
end



