# Changelog

The noteworthy changes for each ViewPartialFormBuilder version are included
here. For a complete changelog, see the [commits] for each version via the
version links.

[commits]: https://github.com/seanpdoyle/view_partial_form_builder/commits/master

## master

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
