window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.ElementsWindow =

  init: (url, options, callback) ->
    @url = url
    @callback = callback
    window.requestAnimationFrame =>
      spinner = new Alchemy.Spinner('medium')
      spinner.spin @element_area[0]
    @reload()

  reload: ->
    $.get @url, (data) =>
      @element_area.html data
      Alchemy.GUI.init(@element_area)
      if @callback
        @callback.call()
    .fail (xhr, status, error) =>
      Alchemy.AjaxErrorHandler @element_area, xhr.status, status, error
