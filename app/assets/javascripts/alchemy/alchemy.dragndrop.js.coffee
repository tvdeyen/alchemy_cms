#= require jquery-ui/widgets/draggable
#= require Sortable.min
#
window.Alchemy = {} if typeof (window.Alchemy) is "undefined"

$.extend Alchemy,

  SortableElements: (page_id, form_token, selector = '#element_area .sortable-elements') ->
    $sortable_area = $(selector)

    getTinymceIDs = ($item) ->
      $textareas = $item.find('textarea.has_tinymce')
      $textareas.map(->
        id = this.id.replace(/tinymce_/, '')
        parseInt(id, 10)
      ).get()

    sortable_options =
      handle: '.element-handle'
      ghostClass: 'droppable_element_placeholder'
      animation: 150
      direction: 'vertical'
      onEnd: (event) ->
        $item = $(event.item)
        $parent = $item.parent()
        ids = getTinymceIDs($item)
        Alchemy.Tinymce.init(ids)
        element_ids = $parent.children().map(->
          $(this).data('element-id')
        ).get()
        parent_element_id = $parent.closest('[data-element-id]').data('element-id')
        params =
          page_id: page_id
          authenticity_token: encodeURIComponent(form_token)
          element_ids: element_ids
        if parent_element_id?
          params['parent_element_id'] = parent_element_id
        $.ajax
          url: Alchemy.routes.order_admin_elements_path
          type: 'POST'
          data: params
          complete: ->
            Alchemy.TrashWindow.refresh(page_id)
            return
        return
      onStart: (event) ->
        $item = $(event.item)
        ids = getTinymceIDs($item)
        Alchemy.Tinymce.remove(ids)
        return

    new Sortable($sortable_area[0], sortable_options)
    $sortable_area.find('.nested-elements').each ->
      options = sortable_options
      parentElementName = $(this).closest('.element-editor').data('element-name')
      options.group = parentElementName
      options.direction = undefined
      new Sortable(this, options)
    return

  DraggableTrashItems: ->
    $("#trash_items div.draggable").each ->
      $this = $(this)
      name = $this.data('element-name')
      $dropzone = $("[data-droppable-elements~='#{name}']")
      $this.draggable
        helper: "clone"
        iframeFix: "iframe#alchemy_preview_window"
        connectToSortable: $dropzone
        revert: "invalid"
        revertDuration: 200
        start: (event, ui) ->
          $dropzone.css('minHeight', 36)
          $(this).addClass "dragged"
          ui.helper.css('width', 345)
          return
        stop: (event, ui) ->
          $(this).removeClass "dragged"
          $dropzone.css('minHeight', '')
          ui.helper.css('width', '')
          return
      return
    return
