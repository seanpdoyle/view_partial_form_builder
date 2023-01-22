require "form_builder_test_case"

class ViewPartialFormBuilderFieldNameTest < FormBuilderTestCase
  if Rails.version >= "7.0.0"
    test "delegates field_name to template" do
      render(inline: <<~ERB)
        <%= form_with(model: Post.new) do |form| %>
          <%= form.field_name(:name) %>
        <% end %>
      ERB

      assert_select("form", text: "post[name]")
    end
  end
end
