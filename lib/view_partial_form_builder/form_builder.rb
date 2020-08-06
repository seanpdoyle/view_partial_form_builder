module ViewPartialFormBuilder
  class FormBuilder < ActionView::Helpers::FormBuilder
    attr_reader :default

    def initialize(*)
      super
      @default = dup
      @template = TemplateProxy.new(builder: self, template: @template)
    end
  end
end
