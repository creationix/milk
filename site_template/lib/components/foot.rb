module Milk::Components
  class Foot < Milk::Component
    global_properties :markdown
    markdown_field :markdown, "Footer Text"
  end
end
