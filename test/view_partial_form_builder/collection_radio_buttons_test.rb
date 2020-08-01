require "form_builder_test_case"

class ViewPartialFormBuilderCollectionRadioButtonsTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    choice = OpenStruct.new(post_id: "1", post_name: "one")

    render(locals: {choices: [choice]}, inline: <<~HTML)
      <%= form_with(model: Post.new) do |form| %>
        <%= form.collection_radio_buttons(:name, choices, :post_id, :post_name) %>
      <% end %>
    HTML

    assert_select %(input[type="radio"]), value: choice.post_id
    assert_select "label", text: choice.post_name
  end

  test "renders defaults when overrides are not declared and a block is given" do
    choice = OpenStruct.new(post_id: "1", post_name: "one")

    render(locals: {choices: [choice]}, inline: <<~HTML)
      <%= form_with(model: Post.new) do |form| %>
        <%= form.collection_radio_buttons(:name, choices, :post_id, :post_name) do |builder| %>
          <span id="extra-text">Hello, From Block</span>
          <%= builder.label %>
          <%= builder.radio_button %>
        <% end %>
      <% end %>
    HTML

    assert_select "#extra-text", text: "Hello, From Block"
    assert_select %(input[type="radio"]), value: choice.post_id
    assert_select "label", text: choice.post_name
  end

  test "makes arguments available as local assigns" do
    declare_template "form_builder/_collection_radio_buttons.html.erb", <<~HTML
      <%= form.collection_radio_buttons(
        method,
        collection,
        value_method,
        text_method,
        "data-attr": "foo",
        **html_options,
      ) do |builder| %>
        <%= builder.label(class: "radio-label") %>
        <%= builder.radio_button(class: "radio-input") %>
      <% end %>
    HTML
    choice = OpenStruct.new(post_id: "1", post_name: "one")

    render(locals: {choices: [choice]}, inline: <<~HTML)
      <%= form_with(model: Post.new) do |form| %>
        <%= form.collection_radio_buttons(
          :name,
          choices,
          :post_id,
          :post_name,
        ) %>
      <% end %>
    HTML

    assert_select %(input[type="radio"]), value: choice.post_id
    assert_select "label", text: choice.post_name
  end
end
