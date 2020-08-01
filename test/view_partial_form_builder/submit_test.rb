require "form_builder_test_case"

class ViewPartialFormBuilderSubmitTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.submit %>
      <% end %>
    HTML

    render(partial: "application/form")

    assert_select %(input[type="submit"])
  end

  test "makes invocation flags available through `options`" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.submit("Make Post", class: "my-submit") %>
      <% end %>
    HTML
    declare_template "application/form_builder/_submit.html.erb", <<~'HTML'
      <%= form.submit(
        value,
        class: "submit #{options.delete(:class)}",
        **options,
      ) %>
    HTML

    render(partial: "application/form")

    assert_select %([type="submit"][class="submit my-submit"]), value: "Make Post"
  end

  test "makes `value` available" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.submit("Make Post") %>
      <% end %>
    HTML
    declare_template "application/form_builder/_submit.html.erb", <<~HTML
      <input type="submit" class="my-button" value="<%= value %>">
    HTML

    render(partial: "application/form")

    assert_select("input.my-button", value: "Make Post")
  end

  test "makes `value` available when not passed" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.submit %>
      <% end %>
    HTML
    declare_template "application/form_builder/_submit.html.erb", <<~HTML
      <input type="submit" class="my-button" value="<%= value %>">
    HTML

    render(partial: "application/form")

    assert_select("input", value: "Create Post")
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
    declare_template "application/form_builder/_submit.html.erb", <<~HTML
      <input type="submit" class="my-button" value="<%= value %>">
    HTML

    render(partial: "application/form")

    assert_select("input.my-button", value: "Make Post")
  end
end
