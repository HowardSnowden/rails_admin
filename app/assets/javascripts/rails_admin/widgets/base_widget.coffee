class RailsAdmin.BaseWidget
  element_and_options_of: (event) =>
    element = @element_of(event)
    options = element.data() || element.attr('data')
    [element, options]

  element_of: (event) ->
    $(event.currentTarget)
