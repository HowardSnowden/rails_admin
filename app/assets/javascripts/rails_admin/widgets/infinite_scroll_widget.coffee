class RailsAdmin.InfiniteScrollWidget extends RailsAdmin.BaseWidget
  constructor: ->
    @link_element = '.js_infinite_scroll'

  ready: =>
    link = $(@link_element)
    link.prevAll().hide()
    if link.prev('.next').hasClass('disabled')
      link.addClass('disabled')
    else
      @_bind_link_element()

  _bind_link_element: =>
    $(document).on 'click', @link_element, (event) =>
      element = @element_of(event, true)

      return if element.hasClass('disabled')

      $.ajax(
        url: @_extract_url(element)
        dataType: 'html'
        beforeSend: (xhr) ->
          element.find('a').removeClass('js_infinite_scroll_error')
          element.addClass('disabled')
          xhr.setRequestHeader("Accept", "text/javascript")
        success: (data, status, xhr) =>
          @_prepend_previous_rows(data)
          $(document).trigger('rails_admin.dom_ready')
        error: (xhr, status, error) ->
          element.find('a').addClass('js_infinite_scroll_error')
        complete: (xhr, status) ->
          element.removeClass('disabled')
      )

  _extract_url: (element) ->
    element.prev('.next').find('a').attr('href')

  _prepend_previous_rows: (data) ->
    new_list = $("<div>")
    new_list.html(data)
    container = new_list.find('#list')
    container.find('tbody:last > tr:first').prepend($('tbody:last').html())
    $('#list').html(container.html())
