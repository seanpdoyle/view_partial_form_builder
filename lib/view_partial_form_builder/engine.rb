module ViewPartialFormBuilder
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller_base) do
      default_form_builder ViewPartialFormBuilder::FormBuilder
    end

    ActiveSupport.on_load(:view_partial_form_builder) do
      if Rails::VERSION::MAJOR > 7
        self.aliased_field_helpers = {
          checkbox: [:check_box],
          collection_checkboxes: [:collection_check_boxes],
          rich_textarea: [:rich_text_area]
        }
      end
    end
  end
end
