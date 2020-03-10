require "form_builder_test_case"

class ViewPartialFormBuilderLabelTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.label(:name) %>
      <% end %>
    HTML

    render(partial: "application/form")

    assert_select("label", text: "Name")
  end

  test "renders defaults when overrides are not declared and a block is given" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.label(:name) do %>
          Name
        <% end %>
      <% end %>
    HTML

    render(partial: "application/form")

    assert_select("label", text: "Name")
  end

  test "makes invocation flags available through `options`" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.label(:name, class: "name-label") %>
      <% end %>
    HTML
    declare_template "form_builder/_label.html.erb", <<~HTML
      <% class_names = Array(options.delete(:class)) %>

      <%= form.default.label(method, class: ["my-label"] + class_names) %>
    HTML

    render(partial: "application/form")

    assert_select(".name-label.my-label")
  end

  test "supports arbitrary options" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.label(:name, class: "post-label", required: true) %>
      <% end %>
    HTML
    declare_template "form_builder/_label.html.erb", <<~HTML
      <% required = options.delete(:required) %>

      <%= form.label(method, options) %>
      <% if required %>
        <span>Required</span>
      <% end %>
    HTML

    render(partial: "application/form")

    assert_select(".post-label:not([required])")
    assert_select("span", text: "Required")
  end

  test "passes along blocks properly" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.label(:name) do %>
            Hello, from a block!
        <% end %>
      <% end %>
    HTML
    declare_template "form_builder/_label.html.erb", <<~HTML
      <%= form.label(method) do %>
        <%= yield %>
      <% end %>
    HTML

    render(partial: "application/form")

    assert_select("label", text: "Hello, from a block!")
  end

  test "can pass through all arguments" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.label(:name, "ignored text", class: "label-class") do %>
            Hello, from a block!
        <% end %>
      <% end %>
    HTML
    declare_template "form_builder/_label.html.erb", <<~HTML
      <%= form.label(*arguments, **options, &block) %>
    HTML

    render(partial: "application/form")

    assert_select(%(label[class="label-class"]), text: "Hello, from a block!")
  end
end
