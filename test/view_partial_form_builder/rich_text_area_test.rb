require "form_builder_test_case"

class ViewPartialFormBuilderRichTextAreaTest < FormBuilderTestCase
  def setup
    unless defined?(ActionText)
      skip "Skipping ActionText tests for rails@#{Rails.version}"
    end
  end

  test "renders defaults when overrides are not declared" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.rich_text_area(:name) %>
      <% end %>
    HTML

    render(partial: "application/form")

    assert_select("trix-editor")
  end

  test "renders a field-specific template" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.rich_text_area(:avatar) %>
      <% end %>
    HTML
    declare_template "application/form_builder/_rich_text_area.html.erb", <<~HTML
      <div class="wrapper">
        <%= form.rich_text_area(method, options) %>
      </div>
    HTML

    render(partial: "application/form")

    assert_select(".wrapper trix-editor")
  end
end
