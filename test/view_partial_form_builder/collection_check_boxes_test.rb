require "form_builder_test_case"

class ViewPartialFormBuilderCollectionCheckBoxesTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    choices = [
      OpenStruct.new(post_id: "1", post_name: "one"),
    ]
    declare_template "application/_form.html.erb", <<~HTML
    <%= form_with(model: Post.new) do |form| %>
      <%= form.collection_check_boxes(:name, choices, :post_id, :post_name) %>
    <% end %>
    HTML

    render(partial: "application/form", locals: { choices: choices })

    assert_select %(input[type="checkbox"][value="1"])
    assert_select("label", text: "one")
  end

  test "renders defaults when overrides are not declared and a block is given" do
    choices = [
      OpenStruct.new(post_id: "1", post_name: "one"),
    ]
    declare_template "application/_form.html.erb", <<~HTML
    <%= form_with(model: Post.new) do |form| %>
      <%= form.collection_check_boxes(:name, choices, :post_id, :post_name) do %>
        Hello, From Block
      <% end %>
    <% end %>
    HTML

    render(partial: "application/form", locals: { choices: choices })

    assert_select("form", text: "Hello, From Block")
  end

  test "makes arguments available as local assigns" do
    choices = [
      OpenStruct.new(post_id: "1", post_name: "one"),
    ]
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.collection_check_boxes(
          :name,
          choices,
          :post_id,
          :post_name,
          "data-attr": "foo",
        ) do |builder| %>
          <%= builder.label(class: "checkbox-label") %>
          <%= builder.check_box(class: "checkbox-input") %>
        <% end %>
      <% end %>
    HTML
    declare_template "application/form_builder/_collection_check_boxes.html.erb", <<~HTML
      <%= form.collection_check_boxes(
        method,
        collection,
        value_method,
        text_method,
        options,
        html_options,
        &block
      ) %>
    HTML

    render(partial: "application/form", locals: { choices: choices })

    assert_select %(input[type="checkbox"][class="checkbox-input"][data-attr="foo"]), value: "1"
    assert_select %(label[class="checkbox-label"]), text: "one"
  end
end
