//= require jquery-ui/widgets/draggable
//= require jquery-ui/widgets/sortable
//
var Alchemy = window.Alchemy || {}

$.extend(Alchemy, {
  SortableElements: function SortableElements(page_id, form_token, $selector) {
    function getTinymceIDs(ui) {
      var $textareas = ui.item.find('textarea.has_tinymce')

      return $($textareas).map(function() {
        var id = this.id.replace(/tinymce_/, '')
        return parseInt(id, 10)
      })
    }

    var $sortable_area = $selector || $('#element_area .sortable-elements')
    var sortable_options = {
      items: '> .element-editor',
      handle: '> .element-header .element-handle',
      placeholder: 'droppable_element_placeholder',
      dropOnEmpty: true,
      opacity: 0.5,
      cursor: 'move',
      containment: $('#element_area'),
      tolerance: 'pointer',
      update: function update(event, ui) {
        // This callback is called twice for both elements, the source and the receiving
        // but, we only want to call ajax callback once on the receiving element.
        if (Alchemy.initializedSortableElements) { return }

        var $this = ui.item.parent().closest('.ui-sortable')
        var element_ids = $.map($this.children(), function(child) {
          return $(child).data('element-id')
        })
        var parent_element_id = ui.item.parent().closest('[data-element-id]').data('element-id')
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
      },
      start: function start(_evt, ui) {
        var $this = $(this)
        var name = ui.item.data('element-name')
        var $dropzone = $('[data-droppable-elements~="' + name + '"]')
        var ids = getTinymceIDs(ui)

        $this.sortable('option', 'connectWith', $dropzone)
        $this.sortable('refresh')
        $dropzone.css('minHeight', 36)
        ui.item.addClass('dragged')

        if (ui.item.hasClass('compact')) {
          ui.placeholder.addClass('compact').css({
            height: ui.item.outerHeight()
          })
        }
        Alchemy.Tinymce.remove(ids)
      },
      stop: function stop(_evt, ui) {
        var ids = getTinymceIDs(ui)
        var name = ui.item.data('element-name')
        var $dropzone = $('[data-droppable-elements~="' + name + '"]')

        $dropzone.css('minHeight', '')
        ui.item.removeClass('dragged')
        Alchemy.Tinymce.init(ids)
      }
    }

    Alchemy.initializedSortableElements = false
    $sortable_area.sortable(sortable_options)
    $sortable_area.find('.nested-elements').sortable(sortable_options)
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
