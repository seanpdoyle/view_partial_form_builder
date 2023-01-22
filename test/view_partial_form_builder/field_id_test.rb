require "form_builder_test_case"

class ViewPartialFormBuilderFieldIdTest < FormBuilderTestCase
  if Rails.version >= "7.0.0"
    test "delegates field_id to template" do
      render(inline: <<~ERB)
        <%= form_with(model: Post.new) do |form| %>
          <%= form.field_id(:name) %>
        <% end %>
      ERB

      assert_select("form", text: "post_name")
    end
  end
end
