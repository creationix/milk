class Head < Milk::Component
  global_properties :buttons
  component_array :buttons, "Navigation buttons", :com_class => "Button"
end
