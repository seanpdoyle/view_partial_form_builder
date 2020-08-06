require "form_builder_test_case"

class ViewPartialFormBuilderRadioButtonTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.radio_button(:name, "New") %>
      <% end %>
    HTML

    render(partial: "application/form")

    assert_select %(input[type="radio"][value="New"])
  end

  test "makes invocation flags available through `options`" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.radio_button(:name, "New", class: "name-radio_button") %>
      <% end %>
    HTML
    declare_template "application/form_builder/_radio_button.html.erb", <<~HTML
      <% class_names = Array(options.delete(:class)) %>

      <%= form.radio_button(method, tag_value, class: ["my-radio"] + class_names) %>
    HTML

    render(partial: "application/form")

    assert_select(".name-radio_button.my-radio")
  end

  test "makes `tag_value` available" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new(name: "New")) do |form| %>
        <%= form.radio_button(:name, "New") %>
        <%= form.radio_button(:name, "Old") %>
      <% end %>
    HTML
    declare_template "application/form_builder/_radio_button.html.erb", <<~HTML
      <div class="wrapper">
        <%= form.radio_button(method, tag_value) %>
      </div>
    HTML

    render(partial: "application/form")

    assert_select %([class="wrapper"] [checked][value="New"])
    assert_select %([class="wrapper"] :not([checked])[value="Old"])
  end
end
