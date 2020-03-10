require "form_builder_test_case"

class ViewPartialFormBuilderCheckBoxTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.check_box(:name) %>
      <% end %>
    HTML

    render(partial: "application/form")

    assert_select(%{input[type="checkbox"]})
  end

  test "renders with the appropriate `checked` value" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new(published: true)) do |form| %>
        <%= form.check_box(:published) %>
      <% end %>
    HTML
    declare_template "form_builder/_check_box.html.erb", <<~HTML
      <div class="wrapper">
        <%= form.check_box(method) %>
      </div>
    HTML

    render(partial: "application/form")

    assert_select(".wrapper [checked]")
  end

  test "makes invocation flags available through `options`" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.check_box(:name, class: "name-check_box") %>
      <% end %>
    HTML
    declare_template "form_builder/_check_box.html.erb", <<~HTML
      <% class_names = Array(options.delete(:class)) %>

      <%= form.check_box(method, class: ["my-checkbox"] + class_names) %>
    HTML

    render(partial: "application/form")

    assert_select(".name-check_box.my-checkbox")
  end

  test "makes `checked_value` and `unchecked_value` available" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.check_box(:name, {}, "true", "false") %>
      <% end %>
    HTML
    declare_template "form_builder/_check_box.html.erb", <<~HTML
      <div class="wrapper">
        <%= form.check_box(method, {}, checked_value, unchecked_value) %>
      </div>
    HTML

    render(partial: "application/form")

    assert_select(%{.wrapper input[type="hidden"][value="false"]})
    assert_select(%{.wrapper input[type="checkbox"][value="true"]})
  end
end
