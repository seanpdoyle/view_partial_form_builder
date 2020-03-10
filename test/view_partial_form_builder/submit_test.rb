require "form_builder_test_case"

class ViewPartialFormBuilderSubmitTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.submit %>
      <% end %>
    HTML

    render(partial: "application/form")

    assert_select(%{input[type="submit"]})
  end

  test "makes invocation flags available through `options`" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.submit("Make Post", class: "my-submit") %>
      <% end %>
    HTML
    declare_template "form_builder/_submit.html.erb", <<~HTML
      <% class_names = Array(options.delete(:class)) %>

      <%= form.default.submit(value, class: (["submit"] + class_names)) %>
    HTML

    render(partial: "application/form")

    assert_select(%{[type="submit"][value="Make Post"].submit.my-submit})
  end

  test "makes `value` available" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.submit("Make Post") %>
      <% end %>
    HTML
    declare_template "form_builder/_submit.html.erb", <<~HTML
      <button type="submit" class="my-button"><%= value %></button>
    HTML

    render(partial: "application/form")

    assert_select("button.my-button", text: "Make Post")
  end

  test "makes `value` available when not passed" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.submit %>
      <% end %>
    HTML
    declare_template "form_builder/_submit.html.erb", <<~HTML
      <button type="submit" class="my-button"><%= value %></button>
    HTML

    render(partial: "application/form")

    assert_select("button", text: "Create Post")
  end

  test "makes internationalized `value` when not passed" do
    declare_translations(
      helpers: { submit: { post: { create: "Make %{model}" } } },
    )
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.submit %>
      <% end %>
    HTML
    declare_template "form_builder/_submit.html.erb", <<~HTML
      <button type="submit" class="my-button"><%= value %></button>
    HTML

    render(partial: "application/form")

    assert_select("button.my-button", text: "Make Post")
  end
end
