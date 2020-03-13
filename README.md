# ViewPartialFormBuilder

Construct `<form>` elements and their fields by combining
[`ActionView::Helpers::FormBuilder`][FormBuilder] with [Rails View
Partials][partials].

[FormBuilder]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html
[partials]: https://api.rubyonrails.org/classes/ActionView/PartialRenderer.html

## Usage

### Building the Form

First, render a `<form>` element with [`form_with`][form_with] the necessary
fields:

```html+erb
<%# app/views/users/new.html.erb %>

<%= form_with(model: user) do |form| %>
  <%= form.label(:name) %>
  <%= form.text_field(:name, class: "text-field", required: true) %>

  <%= form.label(:email) %>
  <%= form.email_field(:email, class: "text-field text-field--large", required: true) %>

  <%= form.label(:password) %>
  <%= form.password_field(:email, class: "text-field",  required: true) %>

  <%= form.button(class: "button button--primary") %>
<% end %>
```

### Declaring the Fields' View Partials

Next, declare view partials that correspond to the [`FormBuilder`][FormBuilder]
helper method you'd like to have more control over:

```html+erb
<%# app/views/form_builder/_text_field.html.erb %>

<input
  type="text"
  name="<%= form.object_name %>[<%= method %>]"
  class="text-field"
<% options.each do |attribute, value| %>
  <%= attribute %>="<%= value %>"
<% end %>
>

<%# app/views/form_builder/_email_field.html.erb %>

<input
  type="email"
  name="<%= form.object_name %>[<%= method %>]"
  class="text-field text-field--large"
<% options.each do |attribute, value| %>
  <%= attribute %>="<%= value %>"
<% end %>
>

<%# app/views/form_builder/_button.html.erb %>

<button
  class="button button--primary"
<% options.each do |attribute, value| %>
  <%= attribute %>="<%= value %>"
<% end %>
>
  <%= value %>
</button>
```

You'll have local access to the `FormBuilder` instance as the template-local
`form` variable. You can mix and match between declaring HTML elements, and
generating HTML through Rails' helpers:

```html+erb
<%# app/views/form_builder/_email_field.html.erb %>

<div class="email-field-wrapper">
  <%= form.email_field(method, required: true, **options)) %>
</div>
```

```html+erb
<%# app/views/form_builder/_button.html.erb %>

<div class="button-wrapper">
  <%= form.button(*arguments, **options, &block) %>
</div>
```

Templates with calls to [`FormBuilder#fields`][fields] and
[`FormBuilder::fields_for`][fields_for] will yield instances of
`ViewPartialFormBuilder` as block arguments.

With the exception of `fields` and `fields_for`, view partials for all other
[`FormBuilder` field methods][FormBuilder] can be declared.

When a partial for a helper method is not declared, `ViewPartialFormBuilder`
will fall back to the default helper method's behavior.

[fields]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-fields
[fields_for]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-fields_for

### Arguments

Every view partial has access to the arguments it was invoked with. For example,
the [`FormBuilder#button`][button] accepts two arguments: `method` and `value`.
Arguments are made available as partial-local variables (along with key-value
pairs in the [`local_assigns`][local_assigns]).

In addition, each view partial receives:

* `form` - a reference to the instance of `ViewPartialFormBuilder`, which is a
  descendant of [`ActionView::Helpers::FormBuilder`][FormBuilder]

* `arguments` - an Array containing the arguments the helper received, in the
  order they were received. This can be useful to pass to the view partial's
  helper by [splatting them][splat] out.

* `&block` - a callable, `yield`-able block if the helper method was passed one

In cases when a [`ActionView::Helpers::FormBuilder` helper
method][FormBuilder]'s last arguments are options (either `Hash` instances or
[keyword arguments][]), they're omitted from the `arguments` array.

If you want to pass-through all arguments, options, and block parameters, you
can splat them out:

```html+erb
<%# app/views/form_builder/_label.html.erb %>

<%= form.label(*arguments, **options, &block) %>
```

```html+erb
<%# app/views/form_builder/_select.html.erb %>

<%= form.select(*arguments, **html_options, &block) %>
```

#### Handling DOMTokenList attributes

An [HTML element's `class` attribute][mdn-class] is treated by browsers as a
[`DOMTokenList`][DOMTokenList]:

> set of space-separated tokens. Such a set is returned by
> [`Element.classList`][classList], ...
> [`HTMLAnchorElement.relList`][relList]...
>
> It is indexed beginning with `0` as with JavaScript Array objects.
> `DOMTokenList` is always case-sensitive.

When rendering a field's DOMTokenList-backed attributes (like `class` or
[`"data-controller"` when specifying StimulusJS
controllers][stimulus-controller]), transforming and combining singular `String`
instances into lists of token can be very useful.

To simplify those scenarios, a partial's template-local optional attributes are
made available with the `#merge_token_lists` method.

These optional attributes are available through the `options` or `html_options`
partial-local variables. Their name will depend on the partial's corresponding
[`ActionView::Helpers::FormBuilder`][FormBuilder] interface.

Calls to `#merge_token_lists` will merge the key-value pairs and return a new
Hash-like structure. The attribute's value will be transformed into an `Array`.
Given call to `form.text_field` and a corresponding partial declaration:

```html+erb
  <%# app/views/users/new.html.erb %>
<%= form_with(model: post) do |form| %>
  <%= form.text_field(:name, class: "text-field--modifier") %>
<% end %>

<# app/views/form_builder/_text_field.html.erb %>

<%= form.text_field(*arguments, **options.merge_token_lists(class: "text-field")) %>
```

The resulting HTML `<input>` element will merge have its [`class`
attribute][mdn-class] set to a list containing both sets of ERB-side `class:`
values:

```html
<input type="text" name="post[name]" class="text-field text-field--modifier">
```

[form_with]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with
[button]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-button
[local_assigns]: https://api.rubyonrails.org/classes/ActionView/Template.html#method-i-local_assigns
[splat]: https://ruby-doc.org/core-2.2.0/doc/syntax/calling_methods_rdoc.html#label-Array+to+Arguments+Conversion
[keyword arguments]: https://thoughtbot.com/blog/ruby-2-keyword-arguments
[mdn-class]: https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/class
[DOMTokenList]: https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList
[classList]: https://developer.mozilla.org/en-US/docs/Web/API/Element/classList
[relList]: https://developer.mozilla.org/en-US/docs/Web/API/HTMLAnchorElement/relList
[stimulus-controller]: https://stimulusjs.org/reference/controllers#identifiers

### Rendering the Fields

The fields' view partial files behave like any other: their contents will be
used to populate the original call-site.

To opt-out of view partial rendering for a field, first call `#default` on the
block-local `form` variable:

```erb
<%# app/views/users/form_builder/_email_field.html.erb %>

<%= form.default.email_field(*arguments, **options) %>
```

When passing a `model:` or `scope:` to calls to [`form_with`][form_with],
a pluralized version of the FormBuilder's object name will be prepended to the
look up path.

For example, when calling `form_with(model: User.new)`, a partial declared in
`app/views/users/form_builder/` would take precedent over a partial declared in
`app/views/form_builder/`.

```erb
<%# app/views/users/form_builder/_password_field.html.erb %>

<div class="password-field-wrapper">
  <%= form.password_field(*arguments, **options) %>
</div>
```

If you'd like to render a specific partial for a field, you can declare the name
as the `partial:` option:

```erb
<%# app/views/users/new.html.erb %>

<%= form_with(model: User.new) do |form| %>
  <%= form.email_field(:email, partial: "emails/my_special_text_field") %>
<% end %>
```

### Configuration

View partials lookup and resolution will be scoped to the
`app/views/form_builder` directory.

To override this destination to another directory (for example,
`app/views/fields`, or `app/views/users/fields`), set
`ViewPartialFormBuilder.view_partial_directory`:

```ruby
# config/initializers/view_partial_form_builder.rb
ViewPartialFormBuilder.view_partial_directory = "fields"
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'view_partial_form_builder'
```

And then execute:

```bash
$ bundle
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
