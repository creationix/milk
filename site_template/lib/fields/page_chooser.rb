module Milk::Fields
  class PageChooser < Milk::Field
    @@pages = []
    Dir.glob(Milk::DATA_DIR + "/pages/*.yaml").each do |page|
      pagename = File.basename(page, '.yaml').rpartition('/').last.gsub('.','/')
      @@pages << {
        file: page,
        name: pagename,
        url: "/"+pagename
      }
    end
    
    def pages
      @@pages
    end
  end
end
