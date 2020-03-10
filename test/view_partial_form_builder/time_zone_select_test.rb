require "form_builder_test_case"

class ViewPartialFormBuilderTimeZoneSelectTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    declare_template "application/_form.html.erb", <<~HTML
    <%= form_with(model: Post.new) do |form| %>
      <%= form.time_zone_select(:name, ActiveSupport::TimeZone.us_zones) %>
    <% end %>
    HTML

    render(partial: "application/form")

    assert_select %(option[value="America/Adak"]), text: "(GMT-10:00) America/Adak"
  end

  test "renders arguments as local assigns" do
    declare_template "application/_form.html.erb", <<~HTML
    <%= form_with(model: Post.new) do |form| %>
      <%= form.time_zone_select(
        :name,
        ActiveSupport::TimeZone.us_zones,
        { prompt: true },
        "data-attr": "foo",
      ) %>
    <% end %>
    HTML
    declare_template "form_builder/_time_zone_select.html.erb", <<~HTML
      <p id="method"><%= method %></p>
      <p id="priority_zones"><%= priority_zones.first %></p>
      <p id="options"><%= options.to_json %></p>
      <p id="html_options"><%= html_options.to_json %></p>
    HTML

    render(partial: "application/form")

    assert_select "#method", text: "name"
    assert_select "#priority_zones", text: "(GMT-10:00) America/Adak"
    assert_select "#options", text: { prompt: true }.to_json
    assert_select "#html_options", text: { "data-attr": "foo" }.to_json
  end
end
