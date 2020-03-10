require "form_builder_test_case"

class ViewPartialFormBuilderHiddenFieldTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.hidden_field(:name) %>
      <% end %>
    HTML

    render(partial: "application/form")

    assert_select(%{input[type="hidden"]})
  end

  test "renders a field-specific template" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.hidden_field(:name) %>
      <% end %>
    HTML
    declare_template "form_builder/_hidden_field.html.erb", <<~HTML
      <input type="hidden" name="<%= method %>" hidden>
    HTML

    render(partial: "application/form")

    assert_select(%{input[type="hidden"][name="name"][hidden]})
  end
end
