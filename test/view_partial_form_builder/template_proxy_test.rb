require "test_helper"

class ViewPartialFormBuilder::TemplateProxyTest < ActionView::TestCase
  test "#capture is delegated to the template" do
    render_with_template_proxy <<~ERB
      <% content = template_proxy.capture do %>
        Hello world
      <% end %>

      <%= content %>
    ERB

    assert_equal rendered.strip, "Hello world"
  end

  if Rails.version >= "7.0.0"
    test "#_object_for_form_builder is delegated to the template" do
      model_class = Class.new do
        def to_s
          "Hello from the model"
        end
      end

      render_with_template_proxy <<~ERB, model: model_class.new
        <%= template_proxy._object_for_form_builder(model) %>
      ERB

      assert_equal rendered.strip, "Hello from the model"
    end

    test "#field_id is delegated to the template" do
      render_with_template_proxy <<~ERB
        <%= template_proxy.field_id(:object_name, :method_name) %>
      ERB

      assert_equal rendered.strip, "object_name_method_name"
    end

    test "#field_name is delegated to the template" do
      render_with_template_proxy <<~ERB
        <%= template_proxy.field_name(:object_name, :method_name) %>
      ERB

      assert_equal rendered.strip, "object_name[method_name]"
    end
  end

  def render_with_template_proxy(template, **locals)
    render inline: <<~ERB, locals: {template: template, locals: locals}
      <% template_proxy = ViewPartialFormBuilder::TemplateProxy.new(builder: nil, template: self) %>

      <%= render inline: template, locals: {template_proxy: template_proxy, **locals} %>
    ERB
  end
end
