require "form_builder_test_case"

class ViewPartialFormBuilderCollectionCheckBoxesTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    choice = OpenStruct.new(post_id: "1", post_name: "one")

    render(locals: {choices: [choice]}, inline: <<~HTML)
      <%= form_with(model: Post.new) do |form| %>
        <%= form.collection_check_boxes(:name, choices, :post_id, :post_name) %>
      <% end %>
    HTML

    assert_select %(input[type="checkbox"]), value: choice.post_id
    assert_select "label", text: choice.post_name
  end

  test "renders defaults when overrides are not declared and a block is given" do
    choice = OpenStruct.new(post_id: "1", post_name: "one")

    render(locals: {choices: [choice]}, inline: <<~HTML)
      <%= form_with(model: Post.new) do |form| %>
        <%= form.collection_check_boxes(:name, choices, :post_id, :post_name) do |builder| %>
          <span id="block-text">Hello, From Block</span>
          <%= builder.label %>
          <%= builder.check_box %>
        <% end %>
      <% end %>
    HTML

    assert_select "#block-text", text: "Hello, From Block"
    assert_select %(input[type="checkbox"]), value: choice.post_id
    assert_select "label", text: choice.post_name
  end

  test "makes arguments available as local assigns" do
    declare_template "application/form_builder/_collection_check_boxes.html.erb", <<~HTML
      <%= form.collection_check_boxes(
        method,
        collection,
        value_method,
        text_method,
        options,
        "data-attr": "foo",
        **html_options,
        &block
      ) %>
    HTML
    choice = OpenStruct.new(post_id: "1", post_name: "one")

    render(locals: {choices: [choice]}, inline: <<~HTML)
      <%= form_with(model: Post.new) do |form| %>
        <%= form.collection_check_boxes(
          :name,
          choices,
          :post_id,
          :post_name,
        ) do |builder| %>
          <%= builder.label(class: "checkbox-label") %>
          <%= builder.check_box(class: "checkbox-input") %>
        <% end %>
      <% end %>
    HTML

    assert_select %(input[type="checkbox"][class="checkbox-input"][data-attr="foo"]), value: choice.post_id
    assert_select %(label[class="checkbox-label"]), text: choice.post_name
  end
end
