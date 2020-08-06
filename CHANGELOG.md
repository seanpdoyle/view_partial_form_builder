# Changelog

The noteworthy changes for each ViewPartialFormBuilder version are included
here. For a complete changelog, see the [commits] for each version via the
version links.

[commits]: https://github.com/seanpdoyle/view_partial_form_builder/commits/master

## main

Implement the `FormBuilder` interface by proxying its underlying view
`@template` instance to `ViewPartialFormBuilder::TemplateProxy`.

Remove support for `partial:` option to override which partial is to be rendered
by `ViewPartialFormBuilder::FormBuilder`.

Remove support for declaring option keys as partial-local variables.

Remove support for `*arguments` in a view partial.

Remove support for `merge_token_lists`.

## [0.1.5] - August 06, 2020

Deprecate root-level declarations in `app/views/form_builder/` in favor of
`app/views/application/form_builder/`.

Deprecate support for declaring options keys as partial-local variables.
It will be removed in the `0.2.0` release.

Deprecate support for `*arguments` in a view partial.

It will be removed in the `0.2.0` release.

Deprecate the use of `partial:` to override which partial to be rendered by
`ViewPartialFormBuilder::FormBuilder`. Instead, rely on Rails' controller and
ActiveModel partial scope resolution prefixing.

Deprecate the use of `merge_token_lists` to combine attributes that are backed
by [DOMTokenList][]. It will be removed in the `0.2.0` release.

[DOMTokenList]: https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList

## [0.1.4] - August 06, 2020

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
