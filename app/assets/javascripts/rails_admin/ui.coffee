$ = jQuery
PJAX_TIMEOUT = 2 * 1000

$(document).on "click", "#list input.toggle", ->
  $("#list [name='bulk_ids[]']").prop "checked", $(this).is(":checked")

$(document).on 'click', '.pjax', (event) ->
  if event.which > 1 || event.metaKey || event.ctrlKey
    return
  else if $.support.pjax
    event.preventDefault()
    $.pjax
      container: $(this).data('pjax-container') || '[data-pjax-container]'
      url: $(this).data('href') || $(this).attr('href')
      timeout: PJAX_TIMEOUT
  else if $(this).data('href') # not a native #href, need some help
    window.location = $(this).data('href')

$(document).on 'submit', '.pjax-form', (event) ->
  if $.support.pjax
    event.preventDefault()
    $.pjax
      container: $(this).data('pjax-container') || '[data-pjax-container]'
      url: this.action + (if (this.action.indexOf('?') != -1) then '&' else '?') + $(this).serialize()
      timeout: PJAX_TIMEOUT

$(document).on 'click', '[data-target]', ->
  if !$(this).hasClass('disabled')
    if $(this).has('i.icon-chevron-down').length
      $(this).removeClass('active').children('i').toggleClass('icon-chevron-down icon-chevron-right')
      $($(this).data('target')).select(':visible').hide('slow')
    else
      if $(this).has('i.icon-chevron-right').length
        $(this).addClass('active').children('i').toggleClass('icon-chevron-down icon-chevron-right')
        $($(this).data('target')).select(':hidden').show('slow')

$(document).on 'click', '.form-horizontal legend', ->
  if $(this).has('i.icon-chevron-down').length
    $(this).siblings('.control-group:visible').hide('slow')
    $(this).children('i').toggleClass('icon-chevron-down icon-chevron-right')
  else
    if $(this).has('i.icon-chevron-right').length
      $(this).siblings('.control-group:hidden').show('slow')
      $(this).children('i').toggleClass('icon-chevron-down icon-chevron-right')

$(document).on 'click', 'form .tab-content .tab-pane a.remove_nested_one_fields', ->
  $(this).children('input[type="hidden"]').val($(this).hasClass('active')).
    siblings('i').toggleClass('icon-check icon-trash')

$(document).ready ->
  locale = $('html').attr('lang')
  translations = JSON.parse($('#js_i18n').attr('data'))
  RailsAdmin.I18n.init(locale, translations)
  $(document).trigger('rails_admin.dom_ready')

$(document).on 'pjax:end', ->
  $(document).trigger('rails_admin.dom_ready')

$(document).on 'rails_admin.dom_ready', ->
  $('.animate-width-to').each ->
    length = $(this).data("animate-length")
    width = $(this).data("animate-width-to")
    $(this).animate(width: width, length, 'easeOutQuad')

  $('.form-horizontal legend').has('i.icon-chevron-right').each ->
    $(this).siblings('.control-group').hide()

  $(".table").tooltip selector: "th[rel=tooltip]"

  # Workaround for jquery-ujs formnovalidate issue:
  # https://github.com/rails/jquery-ujs/issues/316
  $('[formnovalidate]').on 'click', ->
    $(this).closest('form').attr('novalidate', true)

  abstract_model = $('#js_abstract_model').attr('data')
  $('.nav.nav-pills li.active').removeClass('active')
  $(".nav.nav-pills li[data-model='#{abstract_model}']").addClass('active')

  eval $('#js_ordered_filters').attr('data')

$(document).on 'click', '#fields_to_export label input#check_all', () ->
  elems = $('#fields_to_export label input')
  if $('#fields_to_export label input#check_all').is ':checked'
    $(elems).prop('checked', true)
  else
    $(elems).prop('checked',false)

# when the user hits the back button, the inline JS <script> that
# highlights the current model in the left menu doesn't get run by
# pjax, so this code runs it:
# https://github.com/defunkt/jquery-pjax/issues/241#issuecomment-13251065
$(document).on 'pjax:popstate', () ->
  $(document).one 'pjax:end', (event) ->
    $(event.target).find('script').each () ->
      $.globalEval(this.text || this.textContent || this.innerHTML || '')
      return
    return
  return

#Remove all filter and then refresh
$(document).on 'click',  "#remove_filter",(event) ->
  event.preventDefault()
  $("#filters_box").html("")
  $("hr.filters_box").hide()
  $(this).parent().siblings("input[type='search']").val("")
  $(this).parents("form").submit()

# For small screens, allow to toggle side menu
SCREEN_SMALL = 768
$(document).on 'click', '.dropdown-header', (event) ->
  if $(window).width() < SCREEN_SMALL
    $(this).nextAll('ul,li').toggle()

$(window).off('resize.rails_admin').on 'resize.rails_admin', (event) ->
  if $(window).width() >= SCREEN_SMALL
    $('.dropdown-header').nextAll('ul,li').show()

# Make link click feel more like native app navigation
NOT_FOUND = -1
$(document).on 'click', 'a.pjax', (event) ->
  active_link = $('.nav.nav-pills li.active a')
  pathname = active_link.attr('href')?.replace(location.origin, '')
  if $(this).attr('href').indexOf(pathname) == NOT_FOUND
    active_link.parent().removeClass('active');

$(document).on 'click', '.nav.nav-pills li', (event) ->
  $(this).addClass('active');

# Infinite pjax timeout
$(document).on 'pjax:timeout', ->
  false

# Load progress bar only if wait time is over 500ms
progress_bar_timeout = null
$(document).on 'pjax:send', ->
  unless progress_bar_timeout?
    progress_bar_timeout = setTimeout(->
      NProgress.start()
    , 500)

$(document).on 'pjax:complete', ->
  NProgress.done()
  clearTimeout(progress_bar_timeout)
  progress_bar_timeout = null

# Widgets
widget_initializers = []
for widget_name, widget_class of RailsAdmin
  if /Widget$/.test(widget_name) && widget_name != 'BaseWidget'
    widget = new widget_class
    widget_initializers.push(widget) if widget.ready?
$(document).on 'rails_admin.dom_ready', ->
  for widget in widget_initializers
    widget.ready()
