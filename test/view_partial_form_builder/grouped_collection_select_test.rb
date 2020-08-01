require "form_builder_test_case"

class ViewPartialFormBuilderGroupedCollectionSelectTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    post = OpenStruct.new(post_id: "1", post_name: "one")
    group = OpenStruct.new(group_name: "group 1", posts: [post])

    render(locals: {groups: [group]}, inline: <<~HTML)
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

    assert_select %(optgroup[label="#{group.group_name}"])
    assert_select %(option), value: post.post_id, text: post.post_name
  end

  test "renders arguments as local assigns" do
    declare_template "application/form_builder/_grouped_collection_select.html.erb", <<~HTML
      <%= form.grouped_collection_select(
        method,
        collection,
        group_method,
        group_label_method,
        option_key_method,
        option_value_method,
        { prompt: true },
        { "data-attr": "foo" },
      ) %>
    HTML
    post = OpenStruct.new(post_id: "1", post_name: "one")
    group = OpenStruct.new(group_name: "group 1", posts: [post])

    render(locals: {groups: [group]}, inline: <<~HTML)
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

    assert_select %(optgroup[label="#{group.group_name}"])
    assert_select %(option), value: group.post_id, text: group.post_name
  end
end
