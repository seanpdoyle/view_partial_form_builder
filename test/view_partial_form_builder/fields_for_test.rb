require "form_builder_test_case"

class FieldsForTest < FormBuilderTestCase
  test "renders defaults when overrides are not declared" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.fields_for(:author, User.new) do |tag_form| %>
          <%= tag_form.text_field(:name) %>
        <% end %>
      <% end %>
    HTML

    render(partial: "application/form")

    assert_select(%(input[type="text"]))
  end

  test "#fields_for passes an instance of ViewPartialFormBuilder to the block" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.fields_for(:author, User.new) do |tag_form| %>
          <%= tag_form.text_field(:name) %>
        <% end %>
      <% end %>
    HTML
    declare_template "application/form_builder/_text_field.html.erb", <<~HTML
      <p><%= method %></p>
    HTML

    render(partial: "application/form")

    assert_select("p", text: "name")
  end

  test "#fields_for cascades templates from most-specific to most general" do
    declare_template "posts/form_builder/_text_field.html.erb", <<~'HTML'
      <%= form.text_field(method, class: "post-text #{options.delete(:class)}", **options) %>
    HTML
    declare_template "application/form_builder/_text_field.html.erb", <<~'HTML'
      <%= form.text_field(method, class: "text #{options.delete(:class)}", **options) %>
    HTML
    post = Post.new(name: "The Post Name")

    render(locals: {post: post}, inline: <<~HTML)
      <%= form_with(url: "#") do |form| %>
        <%= form.fields_for(:post, post) do |post_form| %>
          <%= post_form.text_field(:name, class: "name-text") %>
        <% end %>
      <% end %>
    HTML

    assert_select %([class~="text"][class~="post-text"][class~="name-text"]), value: post.name
  end

  test "#fields passes an instance of ViewPartialFormBuilder to the block" do
    declare_template "application/_form.html.erb", <<~HTML
      <%= form_with(model: Post.new) do |form| %>
        <%= form.fields(model: User.new) do |tag_form| %>
          <%= tag_form.text_field(:name) %>
        <% end %>
      <% end %>
    HTML
    declare_template "application/form_builder/_text_field.html.erb", <<~HTML
      <p><%= method %></p>
    HTML

    render(partial: "application/form")

    assert_select("p", text: "name")
  end

  test "#fields cascades templates from most-specific to most general" do
    declare_template "posts/form_builder/_text_field.html.erb", <<~'HTML'
      <%= form.text_field(method, class: "post-text #{options.delete(:class)}", **options) %>
    HTML
    declare_template "application/form_builder/_text_field.html.erb", <<~'HTML'
      <%= form.text_field(method, class: "text #{options.delete(:class)}", **options) %>
    HTML
    post = Post.new(name: "The Post Name")

    render(locals: {post: post}, inline: <<~HTML)
      <%= form_with(url: "#") do |form| %>
        <%= form.fields(model: post) do |post_form| %>
          <%= post_form.text_field(:name, class: "name-text") %>
        <% end %>
      <% end %>
    HTML

    assert_select %([class~="text"][class~="post-text"][class~="name-text"]), value: post.name
  end
end
