# This section is the milk configs for this local app
module Milk

  SITE_DIR = File.absolute_path(File.dirname(__FILE__)) 

  # SECRET is the site specific key used to encrypt the cookies sent for authentication.
  #
  # It is very important that this key be both long and unique to each site you build.
  #
  # My method is to pick two secret passphrases and concatenating the md5 of them together
  #
  #   >> require 'digest/md5'
  #   => true
  #   >> Digest::MD5.hexdigest("Milk") + Digest::MD5.hexdigest("Rocks")
  #   => "e89b2cbb7d11825a67459af2249064de5cdfbc0ea6e85d2cc3dd5ddec72ffe1a"
  SECRET = "098f6bcd4621d373cade4e832627b4f6ad0234829205b9033196ba818f7a872b"

  # USE_CACHE is an advanced option for sites that need super high performance.  When
  # this option is set to true, then every time a page is saved, a static html file is
  # created and saved to [MILK_ROOT]/public/cache/[pagename]/index.html
  #
  # In order to use these cache files your apache or nginx server needs to have a rewrite
  # rule that looks here first and uses the static files if they exist.
  #
  # As an example, here is the relevent part of my nginx config:
  #
  #   # Enable loading page cache files directly
  #   rewrite ^/$ /cache/Home/index.html;
  #   rewrite ^((/[A-Z][A-Za-z]*)+)$ /cache/$1/index.html;
  USE_CACHE = false

  # This determines what resources depend on what.  That way a page can specify only what it 
  # needs and the rest will be pulled in automatically.
  # Full paths mean to include a file, module name means that module is a dependency.
  DEPENDENCY_TREE = {
    :view => ["/favicon.ico", "/style/reset.css", "/style/text.css", "/style/960.css", "/style/view.css"],
    :jquery => ["/js/jquery-1.3.2.min.js"], 
    :jquery_ui => [:jquery, "/js/jquery-ui-1.7.2.custom.min.js", "/skin/jquery-ui-1.7.2.custom.css"],
    :jquery_json => [:jquery, "/js/jquery.json-1.3.min.js"],
    :form_validate => [:jquery, "/js/form_validate.js"],
    :edit => [:view, :jquery_json, :jquery_ui, "/js/edit.js", "/style/edit.css"],
    :login_form => [:view, :jquery_ui, "/js/login.js", "/style/login.css"]
  }

  # This sets the authorized users to the site.  When we implement an interface to change these
  # settings through the web, then we will move these to a seperate file.  
  # 
  # Hash is a simple md5 of the password for now, future versions of
  # Milk may use something more secure.
  #
  # To create the md5 hash in irb do the following:
  #
  #   >> require 'digest/md5'
  #   => true
  #   >> Digest::MD5.hexdigest("test")
  #   => "098f6bcd4621d373cade4e832627b4f6"
  #
  # Note the default login is admin@example.com/test
  USERS = {
    "admin@example.com" => { :name => "Sample Admin", :hash => "098f6bcd4621d373cade4e832627b4f6" }
  }

end

# This allows for local gems to be used if they exist
Dir.glob(Milk::SITE_DIR+"/vendor/*/lib").each do |path|
  puts "Using local gem at #{path}"
  $LOAD_PATH.unshift(path)
end
require 'milk'

