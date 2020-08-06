require "form_builder_test_case"

class ViewPartialFormBuilderTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.text_field :name %>
      <% end %>
    HTML

    render(partial: "application/form")

    assert_select %(input[type="text"])
  end

  test "makes other view partial-built form fields available" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.text_field :name, class: "name-field" %>
      <% end %>
    HTML
    declare_template "form_builder/_text_field.html.erb", <<~HTML
      <%= form.label(method) %>
      <%= form.text_field(method, **options) %>
    HTML
    declare_template "form_builder/_label.html.erb", <<~HTML
      <label>Label from partial</label>
    HTML

    render(partial: "application/form")

    assert_select(%(label + input[type="text"][class="name-field"]))
    assert_select("label", text: "Label from partial")
  end

  test "renders a ViewPartialFormBuilder partial from within another partial" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= render(partial: "posts/my_text_field", locals: { form: form }) %>
      <% end %>
    HTML
    declare_template "posts/_my_text_field.html.erb", <<~HTML
      <%= form.text_field :name, class: "my-partial-text-field" %>
    HTML
    declare_template "form_builder/_text_field.html.erb", <<~'HTML'
      <%= form.text_field(
        method,
        class: "text-field #{options.delete(:class)}",
        **options,
      ) %>
    HTML

    render(partial: "application/form")

    assert_select %([class~="text-field"][class~="my-partial-text-field"])
  end

  test "renders the most-specific partial available" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.text_field :name %>
      <% end %>
    HTML
    declare_template "form_builder/_text_field.html.erb", <<~HTML
      <input type="text" class="application-input">
    HTML
    declare_template "posts/form_builder/_text_field.html.erb", <<~HTML
      <input type="text" class="post-input">
    HTML

    render(partial: "application/form")

    assert_select %([class="post-input"])
  end

  test "renders with a scope: option" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(scope: :post, url: "/posts") do |form| %>
        <%= form.text_field :name %>
      <% end %>
    HTML
    declare_template "posts/form_builder/_text_field.html.erb", <<~HTML
      <input type="text" class="post-input">
    HTML

    render(partial: "application/form")

    assert_select %([class="post-input"])
  end

  test "within an application directory, fallback to application globals" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.text_field :name %>
      <% end %>
    HTML
    declare_template "form_builder/_text_field.html.erb", <<~HTML
      <input type="text" class="application-input">
    HTML

    render(partial: "application/form")

    assert_select %([class="application-input"])
  end

  test "within a model-related directory, fallback to application globals" do
    declare_template "posts/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.text_field :name %>
      <% end %>
    HTML
    declare_template "form_builder/_text_field.html.erb", <<~HTML
      <input type="text" class="application-input">
    HTML

    render(partial: "posts/form")

    assert_select %([class="application-input"])
  end

  test "within an application directory, look for model-specific partials" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.text_field :name %>
      <% end %>
    HTML
    declare_template "posts/form_builder/_text_field.html.erb", <<~HTML
      <input type="text" class="post-input">
    HTML

    render(partial: "application/form")

    assert_select %([class="post-input"])
  end

  test "renders multiple field elements" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.label(:name, "Not Name!", class: "name-label") %>
        <%= form.text_field(:name) %>
      <% end %>
    HTML
    declare_template "posts/form_builder/_text_field.html.erb", <<~HTML
      <%= form.text_field(:name, class: "post-input") %>
    HTML
    declare_template "form_builder/_label.html.erb", <<~HTML
      <%= form.label(method, text, class: "post-label") %>
    HTML

    render(partial: "application/form")

    assert_select %(input[class="post-input"])
    assert_select "label.post-label", text: "Not Name!"
  end

  test "cascade partials from most-specific to most-general" do
    declare_template "special/posts/form_builder/_text_field.html.erb", <<~'HTML'
      <%= form.text_field(method, class: "special-text #{options.delete(:class)}") %>
    HTML
    declare_template "application/form_builder/_text_field.html.erb", <<~'HTML'
      <%= form.text_field(method, class: "text #{options.delete(:class)}") %>
    HTML
    special_post = Special::Post.new(name: "A Special Post")

    render(locals: {post: special_post}, inline: <<~HTML)
      <%= form_with(model: post, url: "#") do |form| %>
        <%= form.text_field(:name, class: "name-text") %>
      <% end %>
    HTML

    assert_select %(input[class~="special-text"][class~="text"][class~="name-text"]), value: special_post.name
  end

  test "within a model-related directory, look for model-specific partials" do
    declare_template "posts/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.text_field :name %>
      <% end %>
    HTML
    declare_template "posts/form_builder/_text_field.html.erb", <<~HTML
      <input type="text" class="post-input">
    HTML

    render(partial: "posts/form")

    assert_select(".post-input")
  end

  test "interpolates `options` variable" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.text_field :name, class: "post-input" %>
      <% end %>
    HTML
    declare_template "form_builder/_text_field.html.erb", <<~HTML
      <%= form.text_field(method, options) %>
    HTML

    render(partial: "application/form")

    assert_select(".post-input")
  end

  test "specifying a partial name" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.text_field :name, partial: "special_posts/text_field" %>
      <% end %>
    HTML
    declare_template "form_builder/_text_field.html.erb", <<~HTML
      <input type="text" class="application-text-field">
    HTML
    declare_template "special_posts/_text_field.html.erb", <<~HTML
      <p class="partial"><%= local_assigns[:partial] %></p>
      <input type="text" class="special-post-text-field">
    HTML

    render(partial: "application/form")

    assert_select(".special-post-text-field")
    assert_select(".partial", text: "")
  end

  test "exposes a the default helper's arguments and options to template as locals" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.text_field :name, value: "splat!" %>
      <% end %>
    HTML
    declare_template "form_builder/_text_field.html.erb", <<~HTML
      <%= form.text_field(method, **options) %>
    HTML

    render(partial: "application/form")

    assert_select %(input[type="text"][value="splat!"])
  end

  test "provides a means of skipping partial lookup" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.default.text_field :name, class: "default-text-field" %>
      <% end %>
    HTML
    declare_template "form_builder/_text_field.html.erb", <<~HTML
      <input type="text" class="application-text-field">
    HTML

    render(partial: "application/form")

    assert_select(".default-text-field")
    assert_select(":not(.application-text-field)")
  end

  test "can delegate to another partial" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.text_field :name, class: "text--form" %>
      <% end %>
    HTML
    declare_template "posts/form_builder/_text_field.html.erb", <<~'HTML'
      <%= form.text_field(
        method,
        partial: "form_builder/text_field",
        class: "text--admin-partial #{options.delete(:class)}",
        **options,
      ) %>
    HTML
    declare_template "form_builder/_text_field.html.erb", <<~'HTML'
      <%= form.text_field(
        method,
        class: "text #{options.delete(:class)}",
        **options,
      ) %>
    HTML

    render(partial: "application/form")

    assert_select %(input[type="text"][class~="text"][class~="text--form"][class~="text--admin-partial"])
  end

  test "does not recurse infinitely" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.text_field :name, class: "text--form" %>
      <% end %>
    HTML
    declare_template "form_builder/_text_field.html.erb", <<~'HTML'
      <%= form.text_field(
        method,
        partial: "form_builder/text_field",
        class: "text #{options.delete(:class)}",
        **options,
      ) %>
    HTML
    declare_template "posts/form_builder/_text_field.html.erb", <<~'HTML'
      <%= form.text_field(
        method,
        partial: "form_builder/text_field",
        class: "text--post #{options.delete(:class)}",
        **options,
      ) %>
    HTML

    render(partial: "application/form")

    assert_select %(input[type="text"][class~="text"][class~="text--form"][class~="text--post"])
  end
end

class ConfiguredViewPartialFormBuilderTest < FormBuilderTestCase
  def around(&block)
    view_partial_directory = ViewPartialFormBuilder.view_partial_directory

    super(&block)
  ensure
    ViewPartialFormBuilder.view_partial_directory = view_partial_directory
  end

  test "the view partial lookup can be configured" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.text_field :name %>
      <% end %>
    HTML
    declare_template "my_forms/_text_field.html.erb", <<~HTML
      <input type="text" class="my-input">
    HTML

    ViewPartialFormBuilder.view_partial_directory = "my_forms"
    render(partial: "application/form")

    assert_select(%(input[type="text"][class="my-input"]))
  end
end
