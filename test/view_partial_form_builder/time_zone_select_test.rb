require "form_builder_test_case"

class ViewPartialFormBuilderTimeZoneSelectTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    declare_template "application/_form.html.erb", <<~HTML
    HTML

    render(inline: <<~HTML)
      <%= form_with(model: Post.new) do |form| %>
        <%= form.time_zone_select(:name, ActiveSupport::TimeZone.us_zones, {prompt: true}) %>
      <% end %>
    HTML

    assert_select %(select[name="post[name]"]) do
      assert_select %(option[value=""])
      assert_select %(option[value="America/Adak"]), text: "(GMT-10:00) America/Adak", count: 1
    end
  end

  test "renders arguments as local assigns" do
    declare_template "application/form_builder/_time_zone_select.html.erb", <<~HTML
      <%= form.time_zone_select(
        method,
        priority_zones,
        options.merge(prompt: true),
        "data-attr": "foo",
        **html_options
      ) %>
    HTML

    render(inline: <<~HTML)
      <%= form_with(model: Post.new) do |form| %>
        <%= form.time_zone_select(:name, ActiveSupport::TimeZone.us_zones) %>
      <% end %>
    HTML

    assert_select %(select[data-attr="foo"][name="post[name]"]) do
      assert_select %(option[value=""])
      assert_select %(option[value="America/Adak"]), text: "(GMT-10:00) America/Adak", count: 1
    end
  end
end
