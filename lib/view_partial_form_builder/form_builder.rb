module ViewPartialFormBuilder
  class FormBuilder < ActionView::Helpers::FormBuilder
    class_attribute :aliased_field_helpers, default: {}

    attr_reader :default

    def initialize(*)
      super
      @default = dup
      @template = TemplateProxy.new(builder: self, template: @template)
    end
  end

  ActiveSupport.run_load_hooks(:view_partial_form_builder, FormBuilder)
end
