module Milk::Fields
  class SpriteChooser < Milk::Field
    
    def initialize(*args)
      super(*args)
      @sprites = []
      open(Milk::COMPONENTS_DIR+"/sprites.sass") do |sass|
        sass.each do |line|
          if match = @icon_classes.match(line)
            @sprites << {
              css_class: @main_class + " " + match[1],
              name: match[2]
            }
          end
        end
      end
    end
  end
end
