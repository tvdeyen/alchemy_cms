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
    'click .element-header': 'focus',
    'dblclick .element-header': 'toggle',
    'click .ajax-folder': 'toggle',
    'click .publish-element-button a': 'publish',
    'submit .element-form': '_saveContents'
  },

  initialize() {
    this.element_id = this.model.get('id');
    this.$element_area = $('#element_area');
    this.model.on('change', () => this.render());
    if (this.model.contents.length > 0) {
      this.$el.addClass('with-contents');
      // Re-enable the button after persisting state to the server
      this.model.contents.on('sync', () => {
        this._afterSaveContents();
      });
    }
  },

  render() {
    this.$el.html(this.template(this.model.attributes));
    this.$submit = this.$(`button[form="element-${this.element_id}-form"]`);
    // Render all content views unless element is folded
    if (!this.model.get('folded')) {
      this._renderContentViews();
    }
  },

  // Focus element editor.
  //
  // Triggers custom 'SelectPreviewElement.Alchemy' event on target element in preview frame.
  //
  focus() {
    $('.element-editor', this.$element_area).removeClass('selected');
    this.$el.addClass('selected');
    this.$element_area.scrollTo(this.$el, this.SCROLL_TO_OPTIONS);
    this._selectElementInPreview();
    return false;
  },

  // Expands or folds an element editor
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

  // Publishes or unpublishes an element
  //
  publish() {
    this.model.set('public', !this.model.get('public'));
    return false;
  },

  // Selects and scrolls to element with given id in the preview window.
  //
  _selectElementInPreview() {
    let $frame_elements = document.getElementById("alchemy_preview_window")
      .contentWindow.jQuery("[data-alchemy-element]");
    let $selected_element = $frame_elements
      .closest(`[data-alchemy-element="${this.element_id}"]`);
    $selected_element.trigger('SelectPreviewElement.Alchemy');
  },

  _toggleFold() {
    this.model.set('folded', !this.model.get('folded'));
    Alchemy.setElementClean(this.$el);
  },

  _renderContentViews() {
    let $content_area = this.$('.element-content-editors');
    _.each(this.model.contents.models, (content) => {
      // Render the view for content's essence class with data from content's essence model
      let essence_class_name = content.get('essence_class_name');
      let essence_view_class = Alchemy.Views[essence_class_name];

      if (essence_view_class) {
        let view = new essence_view_class({model: content});
        view.$el.appendTo($content_area);
        view.render();
      } else {
        console.warn(`No Backbone view found for ${essence_class_name}!`);
      }
    });
  },

  _saveContents() {
    Alchemy.Buttons.disable(this.$submit);
    this.model.contents.save();
    return false;
  },

  _afterSaveContents() {
    Alchemy.Buttons.enableButton(this.$submit);
    Alchemy.setElementClean(this.$el);
    if (Alchemy.PreviewWindow) {
      Alchemy.PreviewWindow.reload();
    }
  }
});
