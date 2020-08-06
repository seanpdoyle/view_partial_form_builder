require "form_builder_test_case"

class ViewPartialFormBuilderCollectionSelectTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    choices = [
      OpenStruct.new(post_id: "1", post_name: "one"),
    ]
    declare_template "application/_form.html.erb", <<~HTML
    <%= form_with(model: Post.new) do |form| %>
      <%= form.collection_select(:name, choices, :post_id, :post_name) %>
    <% end %>
    HTML

    render(partial: "application/form", locals: { choices: choices })

    assert_select %(option[value="1"]), text: "one"
  end

  test "makes arguments available as local assigns" do
    choices = [
      OpenStruct.new(post_id: "1", post_name: "one"),
    ]
    declare_template "application/_form.html.erb", <<~HTML
    <%= form_with(model: Post.new) do |form| %>
      <%= form.collection_select(
        :name,
        choices,
        :post_id,
        :post_name,
        { prompt: true },
        "data-attr": "foo",
      ) %>
    <% end %>
    HTML
    declare_template "application/form_builder/_collection_select.html.erb", <<~HTML
      <p id="method"><%= method %></p>
      <p id="collection"><%= collection.first.post_name %></p>
      <p id="value_method"><%= value_method %></p>
      <p id="text_method"><%= text_method %></p>
      <p id="options"><%= options.to_json %></p>
      <p id="html_options"><%= html_options.to_json %></p>
    HTML

    render(partial: "application/form", locals: { choices: choices })

    assert_select "#method", text: "name"
    assert_select "#collection", text: "one"
    assert_select "#value_method", text: "post_id"
    assert_select "#text_method", text: "post_name"
    assert_select "#options", text: { prompt: true }.to_json
    assert_select "#html_options", text: { "data-attr": "foo" }.to_json
  end
end
