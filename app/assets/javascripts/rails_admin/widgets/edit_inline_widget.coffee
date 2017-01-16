class RA.EditInlineWidget extends RA.BaseWidget
  constructor: ->
    @text_element = '.js_edit_inline_text'
    @input_element = '.js_edit_inline_input'
    @_bind_text_element()
    @_bind_input_element()

  _bind_text_element: =>
    $(document).on 'click', @text_element, (event) =>
      element = @element_of(event)

      input_wrapper = element.next(@input_element)
      input_wrapper.show()
      input_wrapper.find('input').focus()
      element.hide()

  _bind_input_element: =>
    $(document).on 'blur', @input_element, (event) =>
      [element, options] = @element_and_options_of(event)

      text_wrapper = element.prev(@text_element)
      input = element.find('input')
      form = @_build_form(input, text_wrapper, options)
      unless form?
        text_wrapper.removeClass('edit_inline_error')
        text_wrapper.show()
        element.hide()
        return
      @_send_form(input, text_wrapper, form, options)
      text_wrapper.show()
      element.hide()

  _build_form: (input, text_wrapper, options) =>
    field_name = "#{options.model.replace('~', '_')}[#{options.name}]"
    field_value =
      switch input.attr('type')
        when 'checkbox'
          input.is(':checked')
        else
          input.val()
    if "#{field_value}" == input.attr('value')
      null
    else
      {
        authenticity_token: $('meta[name=csrf-token]').attr('content')
        "#{field_name}": field_value
      }

  _send_form: (input, text_wrapper, form, options) =>
    $.ajax(
      url: @_extract_url(options)
      type: 'PUT'
      data: form
      dataType: 'text'
      success: (data, status, xhr) ->
        data = JSON.parse(data)
        text_wrapper.html(data.title)
        text_wrapper.attr('title', text_wrapper.text())
        text_wrapper.removeClass('edit_inline_error')
        input.attr('value', data.value)
      error: (xhr, status, error) ->
        text_wrapper.addClass('edit_inline_error')
    )

  _extract_url: (options) ->
    root = location.pathname.replace(options.model, '')
    "#{root}#{options.model}/#{options.id}/edit.js?inline=true"
