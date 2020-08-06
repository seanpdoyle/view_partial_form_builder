require "test_helper"
require "template_declaration_helpers"

class Admin::PostsControllerTest < ActionDispatch::IntegrationTest
  include TemplateDeclarationHelpers

  test "renders most specific field partial available"  do
    declare_template "admin/posts/new.html.erb", <<~HTML
    <%= form_with(model: Post.new) do |form| %>
      <%= form.text_field :name %>
    <% end %>
    HTML
    declare_template "application/form_builder/_text_field.html.erb", <<~HTML
      <input type="text" class="application-input">
    HTML
    declare_template "admin/posts/form_builder/_text_field.html.erb", <<~HTML
      <input type="text" class="admin-post-input" name="post[<%= method %>]">
    HTML

    get new_admin_post_path

    assert_select %(.admin-post-input[name="post[name]"])
    assert_select ":not(.application-input)"
  end

  test "renders field partial declared within the same view namespace"  do
    declare_template "admin/posts/new.html.erb", <<~HTML
    <%= form_with(model: Post.new) do |form| %>
      <%= form.text_field :name %>
    <% end %>
    HTML
    declare_template "application/form_builder/_text_field.html.erb", <<~HTML
      <input type="text" class="application-input">
    HTML
    declare_template "admin/application/form_builder/_text_field.html.erb", <<~HTML
      <input type="text" class="admin-input" name="<%= method %>">
    HTML

    get new_admin_post_path

    assert_select %(.admin-input[name="name"])
    assert_select ":not(.application-input)"
  end
end
