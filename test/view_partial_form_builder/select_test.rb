require "form_builder_test_case"

class ViewPartialFormBuilderSelectTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    render(inline: <<~HTML)
      <%= form_with(model: Post.new) do |form| %>
        <%= form.select(:name, [["Option", "value"]]) %>
      <% end %>
    HTML

    assert_select %(option[value="value"]), text: "Option"
  end

  test "renders defaults with block when overrides are not declared" do
    render(inline: <<~HTML)
      <%= form_with(model: Post.new) do |form| %>
        <%= form.select(:name) do %>
          <option value="value">Option</option>
        <% end %>
      <% end %>
    HTML

    assert_select %(option[value="value"]), text: "Option"
  end

  test "makes arguments available as local assigns without block" do
    declare_template "application/form_builder/_select.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.select(
          method,
          choices,
          { prompt: true },
          "data-attr": "foo",
        ) %>
      <% end %>
    HTML
    choice = ["one", "1"]

    render(locals: {choices: [choice]}, inline: <<~HTML)
      <%= form_with(model: Post.new) do |form| %>
        <%= form.select(:name, choices) %>
      <% end %>
    HTML

    assert_select %(select[data-attr="foo"]) do
      assert_select %(option[value=""]), count: 1
      assert_select %(option[value="#{choice.last}"]), text: choice.first, count: 1
    end
  end

  test "makes arguments available as local assigns with block" do
    declare_template "application/form_builder/_select.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.select(
          method,
          choices,
          {},
          "data-attr": "foo",
          &block
        ) %>
      <% end %>
    HTML
    choice = ["one", "1"]

    render(locals: {choices: [choice]}, inline: <<~HTML)
      <%= form_with(model: Post.new) do |form| %>
        <%= form.select(:name) do %>
          <option value="">Pick a thing</option>
          <% choices.each do |text, value| %>
            <option value="<%= value %>"><%= text %></option>
          <% end %>
        <% end %>
      <% end %>
    HTML

    assert_select %(select[data-attr="foo"]) do
      assert_select %(option[value=""]), text: "Pick a thing", count: 1
      assert_select %(option[value="#{choice.last}"]), text: choice.first, count: 1
    end
  end
end
