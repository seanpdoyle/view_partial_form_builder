require "form_builder_test_case"

class ViewPartialFormBuilderButtonTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.button %>
      <% end %>
    HTML

    render(partial: "application/form")

    assert_select("button")
  end

  test "makes invocation flags available through `options`" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.button("Make Post", class: "button") %>
      <% end %>
    HTML
    declare_template "application/form_builder/_button.html.erb", <<~HTML
      <% class_names = Array(options.delete(:class)) %>

      <%= form.button(value, class: (["my-button"] + class_names)) %>
    HTML

    render(partial: "application/form")

    assert_select("button.button.my-button", text: "Make Post")
  end

  test "makes `value` available" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.button("Make Post") %>
      <% end %>
    HTML
    declare_template "application/form_builder/_button.html.erb", <<~HTML
      <button class="custom"><%= value %></button>
    HTML

    render(partial: "application/form")

    assert_select("button.custom", text: "Make Post")
  end

  test "makes `value` available when not passed" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.button %>
      <% end %>
    HTML
    declare_template "application/form_builder/_button.html.erb", <<~HTML
      <button class="custom"><%= value %></button>
    HTML

    render(partial: "application/form")

    assert_select("button.custom", text: "Create Post")
  end

  test "makes internationalized `value` when not passed" do
    declare_translations(
      helpers: { submit: { post: { create: "Make %{model}" } } },
    )
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.button %>
      <% end %>
    HTML
    declare_template "application/form_builder/_button.html.erb", <<~HTML
      <button type="button" class="my-button"><%= value %></button>
    HTML

    render(partial: "application/form")

    assert_select("button.my-button", text: "Make Post")
  end
end
