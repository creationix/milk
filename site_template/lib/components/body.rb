module Milk::Components
  class Body < Milk::Component
    local_properties :markdown
    markdown_field :markdown, "Content"
  end
end
