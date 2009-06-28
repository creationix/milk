module Milk::Fields
  class ImageChooser < Milk::Field
    @@images = []
    IMAGE_DIR = Milk::PUBLIC_DIR + "/images"
    Dir.glob(IMAGE_DIR + "/*").each do |img|
      @@images << {
        size: File.size(img),
        url: img.sub(Milk::PUBLIC_DIR, ''),
        filename: img.rpartition('/').last
      }
    end
    
    def images
      @@images
    end
    
    def alt_form_field
      @prefix.rpartition(':').first + ":#{@alt_field}"
    end
    
    def alt_value
      @component.instance_variable_get('@' + @alt_field.to_s)
    end

  end
end
