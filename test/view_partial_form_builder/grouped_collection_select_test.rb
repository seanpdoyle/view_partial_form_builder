require "form_builder_test_case"

class ViewPartialFormBuilderGroupedCollectionSelectTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    groups = [
      OpenStruct.new(group_name: "group 1", posts: [
        OpenStruct.new(post_id: "1", post_name: "one"),
      ]),
    ]
    declare_template "application/_form.html.erb", <<~HTML
    <%= form_with(model: Post.new) do |form| %>
      <%= form.grouped_collection_select(
        :name,
        groups,
        :posts,
        :group_name,
        :post_id,
        :post_name,
      ) %>
    <% end %>
    HTML

    render(partial: "application/form", locals: { groups: groups })

    assert_select %(optgroup[label="group 1"])
    assert_select %(option[value="1"]), text: "one"
  end

  test "renders arguments as local assigns" do
    groups = [
      OpenStruct.new(group_name: "group 1", posts: [
        OpenStruct.new(post_id: "1", post_name: "one"),
      ]),
    ]
    declare_template "application/_form.html.erb", <<~HTML
    <%= form_with(model: Post.new) do |form| %>
      <%= form.grouped_collection_select(
        :name,
        groups,
        :posts,
        :group_name,
        :post_id,
        :post_name,
        { prompt: true },
        { "data-attr": "foo" },
      ) %>
    <% end %>
    HTML
    declare_template "form_builder/_grouped_collection_select.html.erb", <<~HTML
      <p id="collection_count"><%= collection.count %></p>
      <p id="group_method"><%= group_method %></p>
      <p id="group_label_method"><%= group_label_method %></p>
      <p id="option_key_method"><%= option_key_method %></p>
      <p id="option_value_method"><%= option_value_method %></p>
      <p id="options"><%= options.to_json %></p>
      <p id="html_options"><%= html_options.to_json %></p>
    HTML

    render(partial: "application/form", locals: { groups: groups })

    assert_select "#collection_count", text: "1"
    assert_select "#group_method", text: "posts"
    assert_select "#group_label_method", text: "group_name"
    assert_select "#option_key_method", text: "post_id"
    assert_select "#option_value_method", text: "post_name"
    assert_select "#options", text: { prompt: true }.to_json
    assert_select "#html_options", text: { "data-attr": "foo" }.to_json
  end
end
