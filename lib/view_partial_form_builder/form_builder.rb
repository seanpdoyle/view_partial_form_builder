require "view_partial_form_builder/lookup_context"
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
      @lookup_context = LookupContext.new(
        overridden_context: @template.lookup_context,
        object_name: object_name,
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

    attr_reader :lookup_context

    def render_partial(field, locals, fallback:, &block)
      options = locals.fetch(:options, {})
      partial_override = options.delete(:partial)

      if about_to_recurse_infinitely?(field, partial_override)
        fallback.call
      else
        locals = objectify_options(options).merge(locals, form: self)

        lookup_context.override do
          if partial_override.present?
            render(partial_override, locals, &block)
          elsif partial_exists?(field)
            render(field, locals, &block)
          else
            fallback.call
          end
        end
      end
    end

    def partial_exists?(template_name)
      template_is_partial = true

      lookup_context.template_exists?(
        template_name,
        lookup_context.prefixes,
        template_is_partial,
      )
    end

    def render(partial_name, locals, &block)
      if block.present?
        @template.render(layout: partial_name, locals: locals, &block)
      else
        @template.render(partial: partial_name, locals: locals)
      end
    end

    def about_to_recurse_infinitely?(field, partial_override)
      @template.instance_eval do
        current_partial = @virtual_path.gsub("/_", "/")
        currently_rendering_field = current_partial.end_with?(field)

        return true if currently_rendering_field && partial_override.nil?
        return true if currently_rendering_field && partial_override == current_partial
      end
    end
  end
end
