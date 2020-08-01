module ViewPartialFormBuilder
  class FormBuilder < ActionView::Helpers::FormBuilder
    attr_reader :default

    def initialize(*)
      super
      @default = dup
      @template = TemplateProxy.new(builder: self, template: @template)
    end

    def _object_for_form_builder(object)
      object.is_a?(Array) ? object.last : object
    end
  end
end
