require "test_helper"
require "template_declaration_helpers"

class Admin::PostsControllerTest < ActionDispatch::IntegrationTest
  include TemplateDeclarationHelpers

  test "chooses most specific field partial available"  do
    declare_template "admin/posts/new.html.erb", <<~HTML
    <%= form_with(model: Post.new) do |form| %>
      <%= form.text_field :name %>
    <% end %>
    HTML
    declare_template "application/_text_field.html.erb", <<~HTML
      <input type="text" class="application-post-input">
    HTML
    declare_template "admin/posts/_text_field.html.erb", <<~HTML
      <input type="text" class="admin-post-input" name="post[<%= method %>]">
    HTML

    get new_admin_post_path

    assert_select(%{.admin-post-input[name="post[name]"]})
    assert_select(":not(.application-post-input)")
  end
end
