module ViewPartialFormBuilder
  class FormBuilder < ActionView::Helpers::FormBuilder
    attr_reader :default

    def initialize(*)
      super

      @default = ActionView::Helpers::FormBuilder.new(
        object_name,
        object,
        @template,
        options,
      )
      @lookup_override = LookupOverride.new(
        prefixes: @template.lookup_context.prefixes,
        object_name: object&.model_name || object_name,
        view_partial_directory: ViewPartialFormBuilder.view_partial_directory,
      )
    end

    def label(method, text = nil, **options, &block)
      locals = {
        method: method,
        text: text,
        options: options,
        block: block,
      }

      render_partial("label", locals, fallback: -> { super }, &block)
    end

    def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
      locals = {
        method: method,
        options: options,
        checked_value: checked_value,
        unchecked_value: unchecked_value,
      }

      render_partial("check_box", locals, fallback: -> { super })
    end

    def radio_button(method, tag_value, **options)
      locals = {
        method: method,
        tag_value: tag_value,
        options: options,
      }

      render_partial("radio_button", locals, fallback: -> { super })
    end

    def select(method, choices = nil, options = {}, **html_options, &block)
      html_options = @default_html_options.merge(html_options)

      locals = {
        method: method,
        choices: choices,
        options: options,
        html_options: html_options,
        block: block,
      }

      render_partial("select", locals, fallback: -> { super }, &block)
    end

    def collection_select(method, collection, value_method, text_method, options = {}, **html_options)
      html_options = @default_html_options.merge(html_options)

      locals = {
        method: method,
        collection: collection,
        value_method: value_method,
        text_method: text_method,
        options: options,
        html_options: html_options,
      }

      render_partial("collection_select", locals, fallback: -> { super })
    end

    def collection_check_boxes(method, collection, value_method, text_method, options = {}, **html_options, &block)
      html_options = @default_html_options.merge(html_options)

      locals = {
        method: method,
        collection: collection,
        value_method: value_method,
        text_method: text_method,
        options: options,
        html_options: html_options,
        block: block,
      }

      render_partial("collection_check_boxes", locals, fallback: -> { super }, &block)
    end

    def collection_radio_buttons(method, collection, value_method, text_method, options = {}, **html_options, &block)
      html_options = @default_html_options.merge(html_options)

      locals = {
        method: method,
        collection: collection,
        value_method: value_method,
        text_method: text_method,
        options: options,
        html_options: html_options,
        block: block,
      }

      render_partial("collection_radio_buttons", locals, fallback: -> { super }, &block)
    end

    def grouped_collection_select(method, collection, group_method, group_label_method, option_key_method, option_value_method, options = {}, **html_options)
      html_options = @default_html_options.merge(html_options)

      locals = {
        method: method,
        collection: collection,
        group_method: group_method,
        group_label_method: group_label_method,
        option_key_method: option_key_method,
        option_value_method: option_value_method,
        html_options: html_options,
        options: options,
      }

      render_partial("grouped_collection_select", locals, fallback: -> { super })
    end

    def time_zone_select(method, priority_zones = nil, options = {}, **html_options)
      html_options = @default_html_options.merge(html_options)

      locals = {
        method: method,
        priority_zones: priority_zones,
        html_options: html_options,
        options: options,
      }

      render_partial("time_zone_select", locals, fallback: -> { super })
    end

    def date_select(method, options = {}, **html_options)
      locals = {
        method: method,
        options: options,
        html_options: html_options,
      }

      render_partial("date_select", locals, fallback: -> { super })
    end

    def hidden_field(method, **options)
      @emitted_hidden_id = true if method == :id

      locals = {
        method: method,
        options: options,
      }

      render_partial("hidden_field", locals, fallback: -> { super })
    end

    def file_field(method, **options)
      self.multipart = true

      locals = {
        method: method,
        options: options,
      }

      render_partial("file_field", locals, fallback: -> { super })
    end

    def submit(value = nil, **options)
      value, options = nil, value if value.is_a?(Hash)
      value ||= submit_default_value

      locals = {
        value: value,
        options: options,
      }

      render_partial("submit", locals, fallback: -> { super })
    end

    def button(value = nil, **options)
      value, options = nil, value if value.is_a?(Hash)
      value ||= submit_default_value

      locals = {
        value: value,
        options: options,
      }

      render_partial("button", locals, fallback: -> { super })
    end

    DYNAMICALLY_DECLARED = (
      field_helpers +
      [:rich_text_area] -
      [:label, :check_box, :radio_button, :fields_for, :fields, :hidden_field, :file_field]
    )

    DYNAMICALLY_DECLARED.each do |selector|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{selector}(method, **options)
          render_partial(
            "#{selector}",
            {
              method: method,
              options: options,
            },
            fallback: -> { super },
          )
        end
      RUBY
    end

    private

    def render_partial(field, locals, fallback:, &block)
      options = objectify_options(locals.fetch(:options, {}))
      locals = locals.merge(form: self)

      partial = find_partial(field, locals, prefixes: prefixes_after(field))

      if partial.nil? || about_to_recurse_infinitely?(partial)
        fallback.call
      else
        partial.render(@template, locals, &block)
      end
    end

    def find_partial(template_name, locals, prefixes:)
      template_is_partial = true

      @template.lookup_context.find_all(
        template_name,
        prefixes,
        template_is_partial,
        locals.keys,
      ).first.tap do |partial|
        root_directory = ViewPartialFormBuilder.view_partial_directory

        if partial&.virtual_path == "#{root_directory}/_#{template_name}"
          ActiveSupport::Deprecation.new("0.2.0", "ViewPartialFormBuilder").warn(<<~WARNING.strip)
            Declare root-level partials in app/views/application/#{root_directory}/, not app/views/#{root_directory}/.
          WARNING
        end
      end
    end

    def prefixes_after(template_name)
      prefixes = @lookup_override.prefixes
      current_prefix = current_virtual_path.delete_suffix("/_#{template_name}")

      if prefixes.include?(current_prefix)
        prefixes.from(prefixes.index(current_prefix).to_i + 1)
      else
        prefixes
      end
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
  end
end
