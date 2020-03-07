if (typeof (window.Alchemy) === 'undefined') { window.Alchemy = {} }

Alchemy.Pages = {
  // Handles the page publication date fields
  watchPagePublicationState: function watchPagePublicationState() {
    $(document).on('DialogReady.Alchemy', function onDialogReady(_e, $dialog) {
      var $public_on_field = $('#page_public_on', $dialog)
      var $public_until_field = $('#page_public_until', $dialog)
      var $publication_date_fields = $('.page-publication-date-fields', $dialog)

      $('#page_public', $dialog).click(function onClick() {
        var $checkbox = $(this)
        var now = new Date()
        if ($checkbox.is(':checked')) {
          $publication_date_fields.removeClass('hidden')
          $public_on_field[0]._flatpickr.setDate(now)
        } else {
          $publication_date_fields.addClass('hidden')
          $public_on_field.val('')
        }
        $public_until_field.val('')
      })
    })
  },

  parentSelect: function parentSelect(options) {
    $('#q_parent_id_eq').alchemyPageSelect({
      initialSelection: options.initialSelection,
      placeholder: options.placeholder,
      minimumInputLength: 1,
      url: options.url
    }).on('change', function onChange() {
      this.form.submit()
    })
  }
}
