require "form_builder_test_case"

class ViewPartialFormBuilderDateSelectTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    render(inline: <<~ERB)
      <%= form_with(model: Post.new) do |form| %>
        <%= form.date_select(
          :start_date,
          {
            prompt: true,
            order: [:year],
            start_year: 2000,
            end_year: 2001,
          },
          {}
        ) %>
      <% end %>
    ERB

    assert_select %(option[value=""]), count: 1
    assert_select %(option[value="2000"]), text: "2000"
    assert_select %(option[value="2001"]), text: "2001"
  end

  test "renders arguments as local assigns" do
    declare_template "form_builder/_date_select.html.erb", <<~'HTML'
      <%= form.date_select(
        method,
        options.merge(
          prompt: true,
          order: [:year],
          start_year: 2000,
        ),
        class: "year #{html_options.delete(:class)}",
        **html_options
      ) %>
    HTML

    render(inline: <<~ERB)
      <%= form_with(model: Post.new) do |form| %>
        <%= form.date_select(
          :start_date,
          {
            order: [:year],
            end_year: 2001,
          },
          class: "post-year",
          "data-attr": "foo",
        ) %>
      <% end %>
    ERB

    assert_select %(select[class~="year"][class~="post-year"][data-attr="foo"]) do
      assert_select %(option[value=""]), count: 1
      assert_select %(option[value="2000"]), text: "2000"
      assert_select %(option[value="2001"]), text: "2001"
    end
  end
end
