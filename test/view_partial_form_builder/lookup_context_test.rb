require "test_helper"

module ViewPartialFormBuilder
  class LookupContextTest < ActiveSupport::TestCase
    FakeContext = Struct.new(:prefixes)

    test "#override ensures that the original context is rest outside the block" do
      original_context = FakeContext.new(["posts", "application"])
      lookup_context = LookupContext.new(
        overridden_context: original_context,
        object_name: "post",
        view_partial_directory: "forms",
      )

      lookup_context.override do
        assert_not_equal ["posts", "application"], original_context.prefixes
      end

      assert_equal ["posts", "application"], original_context.prefixes
    end

    test "#override ensures the root prefix remains the same" do
      original_context = FakeContext.new(["posts", "application"])
      lookup_context = LookupContext.new(
        overridden_context: original_context,
        object_name: "post",
        view_partial_directory: "forms",
      )

      lookup_context.override do
        *rest, root = original_context.prefixes

        assert_equal "application", root
        assert_includes rest, "posts"
      end
    end

    test "#override ensures the list of prefixes descends in specificity" do
      original_context = FakeContext.new(["admin/users", "users", "application"])
      lookup_context = LookupContext.new(
        overridden_context: original_context,
        object_name: "user",
        view_partial_directory: "form_builder",
      )

      lookup_context.override do
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
          original_context.prefixes,
        )
      end
    end
  end
end
