module Milk::Components
  class Button < Milk::Component
    local_properties :href, :icon, :title, :description

    page_chooser :href, "Link target"
    text_field :title, "Label text"
    text_field :description, "Tooltip"

    def name
      @title + " button"
    end
    
    # highlight if current page shares base folder with target of link
    def css_class
      (page.link_to.split('/')[1] == @href.split('/')[1] || page.link_to?(@href)) && "active"
    end
    
  end
end
