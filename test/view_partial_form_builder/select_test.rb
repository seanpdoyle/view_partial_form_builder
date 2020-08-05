require "form_builder_test_case"

class ViewPartialFormBuilderSelectTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.select(:name, [["Option", "value"]]) %>
      <% end %>
    HTML

    render(partial: "application/form")

    assert_select %(option[value="value"]), text: "Option"
  end

  test "renders defaults with block when overrides are not declared" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.select(:name, [["Option", "value"]]) do %>
          <p>block value</p>
        <% end %>
      <% end %>
    HTML

    render(partial: "application/form")

    assert_select "p", text: "block value"
  end

  test "makes arguments available as local assigns without block" do
    choices = [ "one", "1" ]
    declare_template "application/_form.html.erb", <<~HTML
    <%= form_with(model: Post.new) do |form| %>
      <%= form.select(
        :name,
        choices,
        { prompt: true },
        "data-attr": "foo",
      ) %>
    <% end %>
    HTML
    declare_template "form_builder/_select.html.erb", <<~HTML
      <p id="method"><%= method %></p>
      <p id="choices"><%= choices.to_json %></p>
      <p id="options"><%= options.to_json %></p>
      <p id="html_options"><%= html_options.to_json %></p>
    HTML

    render(partial: "application/form", locals: { choices: choices })

    assert_select "#method", text: "name"
    assert_select "#choices", text: choices.to_json
    assert_select "#options", text: { prompt: true }.to_json
    assert_select "#html_options", text: { "data-attr": "foo" }.to_json
  end

  test "makes arguments available as local assigns with block" do
    choices = [ "one", "1" ]
    declare_template "application/_form.html.erb", <<~HTML
    <%= form_with(model: Post.new) do |form| %>
      <%= form.select(:name) do %>
        <option value="first">First</option>
      <% end %>
    <% end %>
    HTML
    declare_template "form_builder/_select.html.erb", <<~HTML
      <%= form.select(method) do %>
        <%= yield %>
      <% end %>
    HTML

    render(partial: "application/form", locals: { choices: choices })

    assert_select %(option[value="first"]), text: "First", count: 1
    assert_select %(select[name="post[name]"])
  end

  test "can pass through argument, html_options, and block parameters" do
    choices = [ "one", "1" ]
    declare_template "application/_form.html.erb", <<~HTML
    <%= form_with(model: Post.new) do |form| %>
      <%= form.select(
        :name,
        [ ["First", "first"] ],
        { prompt: "Please select" },
        class: "select--modifier",
      ) %>
    <% end %>
    HTML
    declare_template "form_builder/_select.html.erb", <<~'HTML'
      <%= form.select(
        *arguments,
        class: "select #{html_options.delete(:class)}",
        **html_options,
        &block
      ) %>
    HTML

    render(partial: "application/form", locals: { choices: choices })

    assert_select %(option[value=""]), text: "Please select", count: 1
    assert_select %(option[value="first"]), text: "First", count: 1
    assert_select %(select[name="post[name]"][class="select select--modifier"])
  end
end
