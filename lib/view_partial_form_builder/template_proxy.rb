module ViewPartialFormBuilder
  class TemplateProxy
    def initialize(builder:, template:)
      @template = template
      @builder = builder
    end

    def button_tag(value, options, &block)
      render(:button, arguments: [value, options], block: block) do
        @template.button_tag(value, options, &block)
      end
    end

    def submit_tag(value, options)
      render(:submit, arguments: [value, options]) do
        @template.submit_tag(value, options)
      end
    end

    def label(object_name, method, content_or_options = nil, options = nil, &block)
      if content_or_options.is_a?(Hash)
        options.merge! content_or_options
        content = nil
      else
        content = content_or_options
      end

      render(:label, arguments: [method, content, options], block: block) do
        @template.label(object_name, method, content, options, &block)
      end
    end

    def method_missing(name, *arguments, &block)
      arguments_after_object_name = arguments.from(1)

      render(name, arguments: arguments_after_object_name, block: block) do
        if @template.respond_to?(name)
          @template.public_send(name, *arguments, &block)
        else
          super
        end
      end
    end

    def respond_to_missing?(name, include_private = false)
      @template.respond_to_missing?(name, include_private)
    end

    private

    def render(partial_name, arguments:, block: nil, &fallback)
      locals = extract_partial_locals(partial_name, *arguments).merge(
        form: @builder,
        block: block
      )

      partial = find_partial(partial_name, locals)

      if partial.nil? || about_to_recurse_infinitely?(partial)
        fallback.call
      else
        partial.render(@template, locals, &block)
      end
    end

    def extract_partial_locals(form_method, *arguments)
      parameters = @builder.method(form_method).parameters

      parameters.each_with_index.each_with_object({}) { |(tuple, index), locals|
        _type, parameter = tuple

        locals[parameter] = arguments[index]
      }
    end

    def find_partial(template_name, locals)
      current_prefix = current_virtual_path.delete_suffix("/_#{template_name}")
      template_is_partial = true

      @template.lookup_context.find_all(
        template_name,
        lookup_override.prefixes_after(current_prefix),
        template_is_partial,
        locals.keys
      ).first
    end

    def about_to_recurse_infinitely?(partial)
      partial.virtual_path == current_virtual_path
    end

    def current_virtual_path
      if (current_template = @template.instance_values["current_template"])
        current_template.virtual_path.to_s
      else
        @template.instance_values["virtual_path"].to_s
      end
    end

    def lookup_override
      LookupOverride.new(
        prefixes: @template.lookup_context.prefixes,
        object_name: @builder.object&.model_name || @builder.object_name,
        view_partial_directory: ViewPartialFormBuilder.view_partial_directory
      )
    end
  end
end
