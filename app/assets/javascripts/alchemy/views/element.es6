//= require backbone
//= require alchemy/alchemy.dirty
//= require alchemy/alchemy.buttons
//= require alchemy/alchemy.confirm_dialog
//= require jquery_plugins/jquery.scrollTo.min

Alchemy.Views.Element = Backbone.View.extend({
  model: Alchemy.Models.Element,
  className: 'element-editor',
  template: HandlebarsTemplates.element,

  SCROLL_TO_OPTIONS: {
    duration: 400,
    offset: -10
  },

  events: {
    'click .element-header': 'onClick',
    'dblclick .element-header': 'onDoubleClick',
    'click .ajax-folder': 'onDoubleClick',
    'FocusElementEditor.Alchemy': 'onFocusElement',
    'SaveElement.Alchemy': 'onSaveElement',
    'click .publish-element-button a': 'onPublishElement'
  },

  initialize() {
    this.element_id = this.model.get('id');
    this.$element_area = $('#element_area');
    this.$element_editors = $('.element-editor', this.$element_area);
    this.model.on('change', () => this.render());
  },

  render() {
    this.$el.html(this.template(this.model.attributes));
  },

  // Click event handler for element head.
  //
  // - Focuses the element
  // - Triggers custom 'SelectPreviewElement.Alchemy' event on target element in preview frame.
  //
  onClick(e) {
    this.$element_editors.removeClass('selected');
    this.$el.addClass('selected');
    this.$element_area.scrollTo(this.$el, this.SCROLL_TO_OPTIONS);
    this.selectElementInPreview();
    e.preventDefault();
    e.stopPropagation();
    return false;
  },

  // Double click event handler for element head.
  onDoubleClick(e) {
    e.preventDefault();
    e.stopPropagation();
    this.toggle();
    return false;
  },

  onPublishElement(e) {
    this.model.set('public', !this.model.get('public'));
    return false;
  },

  // Expands or folds a element editor
  //
  toggle() {
    if (Alchemy.isElementDirty(this.el)) {
      Alchemy.openConfirmDialog(Alchemy.t('element_dirty_notice'), {
        title: Alchemy.t('warning'),
        ok_label: Alchemy.t('ok'),
        cancel_label: Alchemy.t('cancel'),
        on_ok: ()=> { this._toggleFold(); }
      });
    } else {
      this._toggleFold();
    }
  },

  // Selects and scrolls to element with given id in the preview window.
  //
  selectElementInPreview() {
    let $frame_elements = document.getElementById("alchemy_preview_window")
      .contentWindow.jQuery("[data-alchemy-element]");

    let $selected_element = $frame_elements.closest(`[data-alchemy-element="${this.element_id}"]`);
    $selected_element.trigger('SelectPreviewElement.Alchemy');
  },

  _toggleFold() {
    this.model.set('folded', !this.model.get('folded'));
    Alchemy.setElementClean(this.$el);
  }
});
