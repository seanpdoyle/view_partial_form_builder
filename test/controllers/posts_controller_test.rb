require "test_helper"
require "template_declaration_helpers"

class PostsControllerTest < ActionDispatch::IntegrationTest
  include TemplateDeclarationHelpers

  test "chooses most specific field partial available"  do
    declare_template "posts/new.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.label :name, "Name Label" %>
        <%= form.text_field :name %>
      <% end %>
    HTML
    declare_template "application/form_builder/_text_field.html.erb", <<~HTML
      <input type="text" class="application-post-input">
    HTML
    declare_template "posts/form_builder/_text_field.html.erb", <<~HTML
      <input type="text" class="post-input" name="post[<%= method %>]">
    HTML

    get new_post_path

    assert_select("label", text: "Name Label")
    assert_select(%{.post-input[name="post[name]"]})
    assert_select(":not(.application-post-input)")
  end
end
