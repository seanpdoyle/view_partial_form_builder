require "test_helper"
require "view_partial_form_builder/lookup_override"

module ViewPartialFormBuilder
  class LookupOverrideTest < ActiveSupport::TestCase
    test "#prefixes ensures the root prefix remains the same" do
      prefixes = ["posts", "application"]
      lookup_context = LookupOverride.new(
        prefixes: prefixes,
        object_name: "post",
        view_partial_directory: "forms",
      )

      *rest, root = lookup_context.prefixes

      assert_equal "application", root
      assert_includes rest, "posts"
    end

    test "#prefixes ensures the list of prefixes descends in specificity" do
      prefixes =["admin/users", "users", "application"]
      lookup_context = LookupOverride.new(
        prefixes: prefixes,
        object_name: "user",
        view_partial_directory: "form_builder",
      )

      assert_equal(
        [
          "admin/users/form_builder",
          "admin/form_builder",
          "admin/users",
          "users/form_builder",
          "users",
          "form_builder",
          "application/form_builder",
          "application",
        ],
        lookup_context.prefixes,
      )
    end
  end
end
