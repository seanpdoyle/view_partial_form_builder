require "form_builder_test_case"

class ViewPartialFormBuilderFileFieldTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.file_field(:avatar) %>
      <% end %>
    HTML

    render(partial: "application/form")

    assert_select %(input[type="file"])
  end

  test "renders a field-specific template" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.file_field(:avatar) %>
      <% end %>
    HTML
    declare_template "form_builder/_file_field.html.erb", <<~HTML
      <input type="file" class="custom-file-field">
    HTML

    render(partial: "application/form")

    assert_select %(input[type="file"][class="custom-file-field"])
  end

  test "marks the host form as multi-part" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.file_field(:avatar) %>
      <% end %>
    HTML
    declare_template "form_builder/_file_field.html.erb", <<~HTML
      <input type="file">
    HTML

    render(partial: "application/form")

    assert_select %(form[enctype="multipart/form-data"])
  end
end
