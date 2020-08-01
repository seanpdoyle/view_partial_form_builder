require "form_builder_test_case"

class ViewPartialFormBuilderCollectionSelectTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    choice = OpenStruct.new(text: "Option", value: "value")

    render(inline: <<~HTML, locals:{choices: [choice]})
      <%= form_with(model: Post.new) do |form| %>
        <%= form.collection_select(:name, choices, :value, :text) %>
      <% end %>
    HTML

    assert_select %(option[value="#{choice.value}"]), text: choice.text
  end

  test "makes arguments available as local assigns" do
    declare_template "application/form_builder/_select.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.collection_select(
          method,
          choices,
          :value,
          :text,
          { prompt: true },
          "data-attr": "foo",
        ) %>
      <% end %>
    HTML
    choice = OpenStruct.new(text: "one", value: "1")

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
end
