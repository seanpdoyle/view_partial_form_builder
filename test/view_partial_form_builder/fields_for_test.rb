require "form_builder_test_case"

class FieldsForTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.fields_for(:author, User.new) do |tag_form| %>
          <%= tag_form.text_field(:name) %>
        <% end %>
      <% end %>
    HTML

    render(partial: "application/form")

    assert_select(%(input[type="text"]))
  end

  test "#fields_for passes an instance of ViewPartialFormBuilder to the block" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.fields_for(:author, User.new) do |tag_form| %>
          <%= tag_form.text_field(:name) %>
        <% end %>
      <% end %>
    HTML
    declare_template "form_builder/_text_field.html.erb", <<~HTML
      <p><%= method %></p>
    HTML

    render(partial: "application/form")

    assert_select("p", text: "name")
  end

  test "#fields passes an instance of ViewPartialFormBuilder to the block" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.fields(model: User.new) do |tag_form| %>
          <%= tag_form.text_field(:name) %>
        <% end %>
      <% end %>
    HTML
    declare_template "form_builder/_text_field.html.erb", <<~HTML
      <p><%= method %></p>
    HTML

    render(partial: "application/form")

    assert_select("p", text: "name")
  end
end
