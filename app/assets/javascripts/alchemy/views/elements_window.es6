//= require backbone
//= require alchemy/collections/elements
//= require alchemy/views/element_editors
//= require alchemy/alchemy.spinner
//= require alchemy/alchemy.i18n

Alchemy.Views.ElementsWindow = Backbone.View.extend({
  TOOLBAR_HEIGHT: 46,
  id: 'alchemy_elements_window',
  template: HandlebarsTemplates.elements_window,

  defaults: {
    container: '#main_content',
    top_menu_height: 75,
    element_window_button: '#element_window_button'
  },

  events: {
    'click .js-new-element-button' : '_clickNewElementButton',
    'click #clipboard_button'      : '_clickClipboardButton',
    'click #element_trash_button'  : '_clickTrashButton'
  },

  initialize(page_id, options) {
    this.options = _.extend({}, this.defaults, options);
    this.page_id = page_id;
    this.hidden = false;
    this.$button = $(this.options.element_window_button);
    this.$buttonLabel = this.$button.find('label');
    this.$button.click((e) => {
      this.toggle();
      return false;
    });
    $(this.options.container).append(this.$el);
    $(window).resize(()=> this.resize());
    this.render();
    // TODO: Show spinner and load elements collection and append editors to element area
  },

  render() {
    this.$el.html(this.template());
    this.resize();
    return this;
  },

  resize() {
    let top = this.options.top_menu_height;
    let height = $(window).height() - top;
    this.$el.css({top, height});
    this.$('#element_area').css({height: height - this.TOOLBAR_HEIGHT});
    return height;
  },

  toggle() {
    if (this.hidden) {
      this.$buttonLabel.text(Alchemy.t('hide_elements'));
      this.show();
    } else {
      this.$buttonLabel.text(Alchemy.t('show_elements'));
      this.hide();
    }
    Alchemy.PreviewWindow.resize();
  },

  hide() {
    this.$el.css({right: -400});
    this.hidden = true;
  },

  show() {
    this.$el.css({right: 0});
    this.hidden = false;
  },

  _clickNewElementButton() {
    let url = Alchemy.routes.new_admin_element_path(this.page_id);
    Alchemy.openDialog(url, {
      title: Alchemy.t('New Element'),
      size: '320x125'
    });
    return false;
  },

  _clickClipboardButton() {
    let url = Alchemy.routes.admin_clipboard_path('elements');
    Alchemy.openDialog(url, {
      title: Alchemy.t('Clipboard'),
      size: '400x305'
    });
    return false;
  },

  _clickTrashButton() {
    Alchemy.TrashWindow.open(this.page_id, Alchemy.t('Trash'));
    return false;
  }
});
