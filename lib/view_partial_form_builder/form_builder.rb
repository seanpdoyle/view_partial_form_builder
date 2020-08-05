require "view_partial_form_builder/lookup_override"
require "view_partial_form_builder/html_attributes"

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
        options: HtmlAttributes.new(options),
        block: block,
        arguments: [method, text],
      }

      render_partial("label", locals, fallback: -> { super }, &block)
    end

    def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
      locals = {
        method: method,
        options: HtmlAttributes.new(options),
        checked_value: checked_value,
        unchecked_value: unchecked_value,
        arguments: [method, options, checked_value, unchecked_value],
      }

      render_partial("check_box", locals, fallback: -> { super })
    end

    def radio_button(method, tag_value, **options)
      locals = {
        method: method,
        tag_value: tag_value,
        options: HtmlAttributes.new(options),
        arguments: [method, tag_value],
      }

      render_partial("radio_button", locals, fallback: -> { super })
    end

    def select(method, choices = nil, options = {}, **html_options, &block)
      html_options = @default_html_options.merge(html_options)

      locals = {
        method: method,
        choices: choices,
        options: options,
        html_options: HtmlAttributes.new(html_options),
        block: block,
        arguments: [method, choices, options],
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
        arguments: [method, collection, value_method, text_method, options],
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
        html_options: HtmlAttributes.new(html_options),
        block: block,
        arguments: [
          method,
          collection,
          value_method,
          text_method,
          options,
        ],
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
        html_options: HtmlAttributes.new(html_options),
        block: block,
        arguments: [
          method,
          collection,
          value_method,
          text_method,
          options,
        ],
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
        html_options: HtmlAttributes.new(html_options),
        options: options,
        arguments: [
          method,
          collection,
          group_method,
          group_label_method,
          option_key_method,
          option_value_method,
          options,
        ],
      }

      render_partial("grouped_collection_select", locals, fallback: -> { super })
    end

    def time_zone_select(method, priority_zones = nil, options = {}, **html_options)
      html_options = @default_html_options.merge(html_options)

      locals = {
        method: method,
        priority_zones: priority_zones,
        html_options: HtmlAttributes.new(html_options),
        options: options,
        arguments: [method, priority_zones, options],
      }

      render_partial("time_zone_select", locals, fallback: -> { super })
    end

    def date_select(method, options = {}, **html_options)
      locals = {
        method: method,
        options: options,
        html_options: HtmlAttributes.new(html_options),
        arguments: [method, options, html_options],
      }

      render_partial("date_select", locals, fallback: -> { super })
    end

    def hidden_field(method, **options)
      @emitted_hidden_id = true if method == :id

      locals = {
        method: method,
        options: HtmlAttributes.new(options),
        arguments: [method],
      }

      render_partial("hidden_field", locals, fallback: -> { super })
    end

    def file_field(method, **options)
      self.multipart = true

      locals = {
        method: method,
        options: HtmlAttributes.new(options),
        arguments: [method],
      }

      render_partial("file_field", locals, fallback: -> { super })
    end

    def submit(value = nil, **options)
      value, options = nil, value if value.is_a?(Hash)
      value ||= submit_default_value

      locals = {
        value: value,
        options: HtmlAttributes.new(options),
        arguments: [value],
      }

      render_partial("submit", locals, fallback: -> { super })
    end

    def button(value = nil, **options)
      value, options = nil, value if value.is_a?(Hash)
      value ||= submit_default_value

      locals = {
        value: value,
        options: HtmlAttributes.new(options),
        arguments: [value],
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
              options: HtmlAttributes.new(options),
              arguments: [method],
            },
            fallback: -> { super },
          )
        end
      RUBY
    end

    private

    def render_partial(field, locals, fallback:, &block)
      options = locals.fetch(:options, {})
      partial_override = options.delete(:partial)
      locals = objectify_options(options).merge(locals, form: self)

      partial = if partial_override.present?
        ActiveSupport::Deprecation.new("0.2.0", "ViewPartialFormBuilder").warn(<<~WARNING)
          Providing a `partial:` option for a form field is deprecated.
        WARNING

        find_partial(partial_override, locals, prefixes: [])
      else
        find_partial(field, locals, prefixes: prefixes_after(field))
      end

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
      ).first
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
