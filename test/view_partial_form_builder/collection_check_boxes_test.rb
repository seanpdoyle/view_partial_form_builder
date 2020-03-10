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
        { prompt: true },
        "data-attr": "foo",
      ) do %>
        block value
      <% end %>
    <% end %>
    HTML
    declare_template "form_builder/_collection_check_boxes.html.erb", <<~HTML
      <p id="method"><%= method %></p>
      <p id="collection"><%= collection.first.post_name %></p>
      <p id="value_method"><%= value_method %></p>
      <p id="text_method"><%= text_method %></p>
      <p id="options"><%= options.to_json %></p>
      <p id="html_options"><%= html_options.to_json %></p>
      <p id="block"><%= yield %></p>
    HTML

    render(partial: "application/form", locals: { choices: choices })

    assert_select "#method", text: "name"
    assert_select "#collection", text: "one"
    assert_select "#value_method", text: "post_id"
    assert_select "#text_method", text: "post_name"
    assert_select "#options", text: { prompt: true }.to_json
    assert_select "#html_options", text: { "data-attr": "foo" }.to_json
    assert_select "#block", "block value"
  end
end
