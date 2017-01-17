class RailsAdmin.BaseWidget
  element_and_options_of: (event, prevent = false) =>
    element = @element_of(event, prevent)
    options = element.data() || element.attr('data')
    [element, options]

  element_of: (event, prevent = false) ->
    event.preventDefault() if prevent
    $(event.currentTarget)
