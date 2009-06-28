
desc "Loads the Milk environment, mainly used as a dependency"
task :environment do |t|
  SITE_DIR ||= t.application.original_dir
  require "milk"
end

desc "Compile all the sass files in the component dir and merge into style.css"
task :sass => :environment do
  require 'haml'
  Dir.glob(Milk::TEMPLATE_DIR + "/*.sass").sort.each do |c|
    target_file = Milk::PUBLIC_DIR+"/style/"+(c.gsub(/.*\/([^\/]*)\.sass/) { |m| $1 })+".css"
    puts "Generating #{target_file}"
    open(target_file, "w") do |style|
      open(c, "r") do |file|
        style.write Sass::Engine.new(file.read, :filename=>c, :style=>:compact, :load_paths => [Milk::TEMPLATE_DIR]).render.strip
      end
    end
  end
end

desc "Rebuild the page cache files"
task :cache => :environment do
  cachedir = Milk::PUBLIC_DIR+"/cache"
  FileUtils.rm_rf(cachedir, :verbose=>true)
  Milk::Page.each_page do |page|
    puts "saving #{page.pagename}"
    page.save_to_cache
  end
end

desc "Start up an interactive ruby session with Milk preloaded"
task :console => :environment do
  # Remove the task name from argv so irb doesn't explode
  ARGV.shift

  # Start an irb session with the environment loaded
  require "irb"
  IRB.start(__FILE__)
end

desc "Start up a development server using thin"
task :server do
  exec "thin -R config.ru start"
end





