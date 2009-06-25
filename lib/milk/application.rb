module Milk
  class Application 
    
    PAGE_PATH_REGEX = /^\/([a-zA-Z0-9_]+(\/[a-zA-Z0-9_]+)*)+\/*$/
    EDIT_PATH_REGEX = /^\/([a-zA-Z0-9_]+(\/[a-zA-Z0-9_]+)*)+\/edit\/*$/
    
    attr_reader :req
    
    def initialize(require_ssl=false)
      @require_ssl = require_ssl
    end
    
    def route
      path = @req.path_info
      
      if path == '/'
        # Special case for root
        path = '/Home'
      end
      
      # Fallback to match everything
      regex = /(.*)/
      
      # Route the request to the right callback
      https = @req.env['HTTPS'] == 'on'
      action = case 
        when @req.get?
          case
            when path == "/logout"
              :logout
            when path =~ EDIT_PATH_REGEX
              regex = EDIT_PATH_REGEX
              if @require_ssl && !https
                :https_redirect
              else
                :edit
              end
            when path =~ PAGE_PATH_REGEX
              regex = PAGE_PATH_REGEX
              :view
          end
        when @req.delete?
          if path =~ PAGE_PATH_REGEX
            regex = PAGE_PATH_REGEX
            :delete
          end
        when @req.post?
          if path == '/login'
            :login
          elsif path =~ PAGE_PATH_REGEX
            regex = PAGE_PATH_REGEX
            :preview
          end
        when @req.put?
          if path =~ PAGE_PATH_REGEX
            regex = PAGE_PATH_REGEX
            :save
          end
      end || :not_found
      
      page_name = regex.match(path)[1]
      
      if (action == :view || action == :edit)
        begin 
          page = Milk::Page.find(page_name)
        rescue Milk::PageNotFoundError
          action = :not_found
        end
      end

      if (action == :preview || action == :save)
        page = Milk::Page.json_unserialize(YAML.load(@req.body.read), page_name)
      end
      
      if !@user && [:edit, :save, :delete].include?(action)
        action = :login_form
      end

      return action, page_name, page
    end
    
    def obfuscate(value)
      require 'base64'
      len = Milk::SECRET.length
      result = (0...value.length).collect { |i| value[i].ord ^ Milk::SECRET[i%len].ord }
      Base64.encode64(result.pack("C*"))
    end
    
    def decode(code)
      require 'base64'
      len = Milk::SECRET.length
      value = Base64.decode64(code)
      result = (0...value.length).collect { |i| value[i].ord ^ Milk::SECRET[i%len].ord }
      result.pack("C*")
    end
    
    def hash(email, password)
      require 'digest/md5'
      Digest::MD5.hexdigest("#{password}")
    end
    
    def logout()
      @resp.delete_cookie('auth', :path => "/")
      @resp.redirect(@req.params['dest'])
    end
    
    def flash(message=nil)
      @resp.delete_cookie('flash', :path => "/") unless message
      @resp.set_cookie('flash', :path => "/", :value => message) if message
      @req.cookies['flash']
    end
    
    def login()
      email = @req.params['email']
      if email.length > 0
        user = users[email]
        if user
          expected = user["hash"]
          actual = hash(email, @req.params['password'])
          if actual == expected
            @resp.set_cookie('auth', :path => "/", :value => obfuscate(email), :secure=>@require_ssl, :httponly=>true)
          else
            flash "Incorrect password for user #{email}"
          end
        else
          flash "User #{email} not found"
        end
      else
        flash "Please enter user email and password"
      end
      @resp.redirect(@req.params['dest'])
    end
    
    def users
      users_file = Milk::CONFIG_DIR+"/users.yaml"
      YAML.load(open(users_file).read)
    end
    
    def load_user
      @user = nil
      if current = @req.cookies['auth']
        email = decode(current)
        @user = users[email]
        @resp.delete_cookie('auth', :path => "/") unless @user
      end
    end
    
    # Rack call interface
    def call(env)
      @req = Rack::Request.new(env)
      @resp = Rack::Response.new
      load_user
      
      # Route the request
      action, page_name, @page = route
      
      # Send proper mime types for browsers that claim to accept it
      @resp["Content-Type"] = 
      if env['HTTP_ACCEPT'].include? "application/xhtml+xml"
        "application/xhtml+xml"
        "text/html"
      else
        "text/html"
      end

      case action
        when :not_found
          @resp.status = 404
          page = Milk::Page.find('NotFound')
          Milk::Application.join_tree(page, self)
          @resp.write page.view
        when :view
          Milk::Application.join_tree(@page, self)
          html = @page.view
          @page.save_to_cache(html) if Milk::USE_CACHE
          @resp.write html
        when :https_redirect
          @resp.redirect('https://' +  @req.host + @req.fullpath)
        when :http_redirect
          @resp.redirect('http://' +  @req.host + @req.fullpath)
        when :edit
          Milk::Application.join_tree(@page, self)
          @resp.write @page.edit
        when :save
          Milk::Application.join_tree(@page, self)
          @resp.write @page.save
        when :preview
          Milk::Application.join_tree(@page, self)
          @resp.write @page.preview
        when :login_form
          filename = FIELDS_DIR + "/login.haml"
          @resp.write(::Haml::Engine.new(File.read(filename), :filename => filename).render(self))
        when :login
          login
        when :logout
          logout
        when :access_denied
          @resp.staus = 403
          @resp.write "Access Denied"
        else
          @resp.status = 500
          @resp.write action.to_s
      end
      @resp.finish
    end    

    # method that walks an object linking Milk objects to eachother
    def self.join_tree(obj, parent)
      if [Milk::Page, Milk::Component, Milk::Application].any? {|klass| obj.kind_of? klass}
        obj.parent = parent
        obj.instance_variables.each do |name|
          var = obj.instance_variable_get(name)
          if var.class == Array
            var.each do |subvar|
              join_tree(subvar, obj)
            end
          end
        end
      end
    end
    
  end
  
  class PageNotFoundError < Exception
  end
end

