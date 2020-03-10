require "view_partial_form_builder/form_builder"

module ViewPartialFormBuilder
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller_base) do
      default_form_builder ViewPartialFormBuilder::FormBuilder
    end
  end
end
