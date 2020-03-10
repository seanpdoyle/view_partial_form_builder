require "test_helper"
require "view_partial_form_builder/html_attributes"

module ViewPartialFormBuilder
  class HtmlAttributesTest < ActiveSupport::TestCase
    test "#merge_token_lists combines the arguments with existing options" do
      html_attributes = HtmlAttributes.new(
        class: ["original-class"],
        "data-controller": ["original-controller"],
      )

      attributes = html_attributes.merge_token_lists(
        class: ["added-class"],
        "data-controller": ["added-controller"],
      )

      assert_equal ["added-class", "original-class"], attributes.fetch(:class)
      assert_equal ["added-controller", "original-controller"], attributes.fetch(:"data-controller")
    end

    test "#merge_token_lists prepends the merged tokens" do
      html_attributes = HtmlAttributes.new(class: "block--modifier")

      attributes = html_attributes.merge_token_lists(
        class: ["block"],
      )

      assert_equal ["block", "block--modifier"], attributes.fetch(:class)
    end

    test "#merge_token_lists inserts a list when one does not exist" do
      html_attributes = HtmlAttributes.new

      attributes = html_attributes.merge_token_lists(
        class: ["added-class"],
      )

      assert_equal ["added-class"], attributes.fetch(:class)
    end

    test "#merge_token_lists merges two single items into a list" do
      html_attributes = HtmlAttributes.new(
        class: "original-class",
      )

      attributes = html_attributes.merge_token_lists(
        class: "added-class",
      )

      assert_equal ["added-class", "original-class"], attributes.fetch(:class)
    end

    test "#merge_token_lists merges a single item and a list" do
      html_attributes = HtmlAttributes.new(
        class: "original",
      )

      attributes = html_attributes.merge_token_lists(
        class: ["added"],
      )

      assert_equal ["added", "original"], attributes.fetch(:class)
    end

    test "#merge_token_lists does not merge duplicates" do
      html_attributes = HtmlAttributes.new(
        class: ["original-class"],
        "data-controller": ["original-controller"],
      )

      attributes = html_attributes.merge_token_lists(
        class: "original-class",
        "data-controller": ["original-controller"],
      )

      assert_equal ["original-class"], attributes.fetch(:class)
      assert_equal ["original-controller"], attributes.fetch(:"data-controller")
    end

    test "#merge_token_lists includes unmodified key-value pairs" do
      html_attributes = HtmlAttributes.new(
        class: ["original-class"],
        "data-controller": ["original-controller"],
      )

      attributes = html_attributes.merge_token_lists(
        class: "added-class",
      )

      assert_equal ["added-class", "original-class"], attributes.fetch(:class)
      assert_equal ["original-controller"], attributes.fetch(:"data-controller")
    end

    test "#merge_token_lists returns a new HtmlAttributes instance" do
      html_attributes = HtmlAttributes.new

      attributes = html_attributes.merge_token_lists(
        class: "added-class",
      )
      html_attributes.delete(:class)

      assert_equal ["added-class"], attributes.fetch(:class)
    end

    test "#merge_token_lists accepts an empty Hash" do
      html_attributes = HtmlAttributes.new

      attributes = html_attributes.merge_token_lists

      assert attributes.respond_to?(:merge_token_lists)
    end

    test "#merge returns an instance of HtmlAttributes" do
      html_attributes = HtmlAttributes.new

      attributes = html_attributes.merge(class: "merged-class")

      assert_kind_of HtmlAttributes, attributes
      assert_equal "merged-class", attributes.fetch(:class)
    end

    test "#reverse_merge returns an instance of HtmlAttributes" do
      html_attributes = HtmlAttributes.new(class: "original-class")

      attributes = html_attributes.reverse_merge(class: "ignored")

      assert_kind_of HtmlAttributes, attributes
      assert_equal "original-class", attributes.fetch(:class)
    end

    test "#to_hash returns a Hash" do
      html_attributes = HtmlAttributes.new

      to_hash = html_attributes.to_hash

      assert_kind_of Hash, to_hash
    end

    test "#to_h returns a Hash" do
      html_attributes = HtmlAttributes.new

      to_h = html_attributes.to_h

      assert_kind_of Hash, to_h
    end
  end
end
