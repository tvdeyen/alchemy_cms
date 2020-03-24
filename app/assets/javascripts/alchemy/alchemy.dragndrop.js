//= require sortable/Sortable.min

var Alchemy = window.Alchemy || {}

$.extend(Alchemy, {
  SortableElements: function SortableElements(page_id, form_token, selector) {
    function getTinymceIDs(item) {
      var textareas = item.querySelectorAll('textarea.has_tinymce')

      return Array.from(textareas).map(function map(textarea) {
        var id = textarea.id.replace(/tinymce_/, '')
        return parseInt(id, 10)
      })
    }

    var sortable_area = document.querySelector(selector)

    var sortable_options = {
      handle: '.element-header',
      ghostClass: 'droppable_element_placeholder',
      // dropOnEmpty: true,
      // opacity: 0.5,
      // cursor: 'move',
      // containment: $('#element_area'),
      // tolerance: 'pointer',
      onStart: function start(event) {
        var item = event.item
        // var $this = $(this)
        // var name = item.dataset.elementName
        // var $dropzone = $('[data-droppable-elements~="' + name + '"]')

        // $this.sortable('option', 'connectWith', $dropzone)
        // $this.sortable('refresh')
        // $dropzone.css('minHeight', 36)
        item.classList.add('dragged') // keep?

        // if (item.hasClass('compact')) {
        //   ui.placeholder.addClass('compact').css({
        //     height: item.outerHeight()
        //   })
        // }
        Alchemy.Tinymce.remove(getTinymceIDs(item))
      },
      onEnd: function stop(event) {
        var item = event.item
        // var name = item.data('element-name')
        // var $dropzone = $('[data-droppable-elements~="' + name + '"]')

        // $dropzone.css('minHeight', '')
        item.classList.remove('dragged')
        Alchemy.Tinymce.init(getTinymceIDs(item))
      },
      onSort: function update(event) {
        var item = event.item
        // This callback is called twice for both elements, the source and the receiving
        // but, we only want to call ajax callback once on the receiving element.
        if (Alchemy.initializedSortableElements) { return }

        var $this = item.parent().closest('.ui-sortable')
        var element_ids = $.map($this.children(), function(child) {
          return $(child).data('element-id')
        })
        var parent_element_id = item.parent().closest('[data-element-id]').data('element-id')
        var params = {
          page_id: page_id,
          authenticity_token: encodeURIComponent(form_token),
          element_ids: element_ids
        }

        Alchemy.initializedSortableElements = true
        if (parent_element_id != null) {
          params['parent_element_id'] = parent_element_id
        }
        $(event.target).css('cursor', 'progress')
        $.ajax({
          url: Alchemy.routes.order_admin_elements_path,
          type: 'POST',
          data: params,
          complete: function complete() {
            Alchemy.initializedSortableElements = false
            $(event.target).css('cursor', '')
            Alchemy.TrashWindow.refresh(page_id)
          }
        })
      }
    }

    Alchemy.initializedSortableElements = false

    new Sortable(sortable_area, sortable_options)

    // $sortable_area.sortable(sortable_options)
    // $sortable_area.find('.nested-elements').sortable(sortable_options)
  },

  DraggableTrashItems: function DraggableTrashItems() {
    $('#trash_items div.draggable').each(function() {
      var $this = $(this)
      var name = $this.data('element-name')
      var $dropzone = $('[data-droppable-elements~="' + name + '"]')

      $this.draggable({
        helper: 'clone',
        iframeFix: 'iframe#alchemy_preview_window',
        connectToSortable: $dropzone,
        revert: 'invalid',
        revertDuration: 200,
        start: function start(_evt, ui) {
          $dropzone.css('minHeight', 36)
          $(this).addClass('dragged')
          ui.helper.css('width', 345)
        },
        stop: function stop(_evt, ui) {
          $(this).removeClass('dragged')
          $dropzone.css('minHeight', '')
          ui.helper.css('width', '')
        }
      })
    })
  }
})
