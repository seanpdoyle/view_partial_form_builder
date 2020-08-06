# Changelog

The noteworthy changes for each ViewPartialFormBuilder version are included
here. For a complete changelog, see the [commits] for each version via the
version links.

[commits]: https://github.com/seanpdoyle/view_partial_form_builder/commits/master

## main

Improve support for `fields_for` and `fields` calls to cascade partial
resolution from most-specific to most-general.

## [0.1.3] - August 05, 2020

Add missing support for `date_select` method.

[date_select]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-date_select

Use [ActionView::Template][] instances to render templates instead of
[ActionView::Helpers::RenderingHelper][]-provided `render()` method.

[ActionView::Template]: https://api.rubyonrails.org/classes/ActionView/Template.html
[ActionView::Helpers::RenderingHelper]: https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render

## [0.1.2] - April 16, 2020

Bugfix: when a partial (for example,
`app/views/application/_my_text_field.html.erb`) called the
`ViewPartialFormBuilder` method ending in the same name (in this example:
`app/views/form_builder/_text_field.html.erb`), infinite recursion protection
would kick in, and the field partial would _not_ be rendered.

## [0.1.1] - April 13, 2020

Passing a `partial:` key can be useful for layering partials on top of one
another. Enable rendering partials within partials:

```html+erb
<%# app/views/admin/form_builder/_search_field.html.erb %>

<%= form.search_field(
  *arguments,
  partial: "form_builder/search_field",
  **options.merge_token_lists(
    class: "search-field--admin",
    "data-controller": "focus->admin-search#clearResults",
  ),
) %>
```

## [0.1.0] - April 12, 2020

Construct `<form>` elements and their fields by combining
[`ActionView::Helpers::FormBuilder`][FormBuilder] with [Rails View
Partials][partials].

[FormBuilder]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html
[partials]: https://api.rubyonrails.org/classes/ActionView/PartialRenderer.html
