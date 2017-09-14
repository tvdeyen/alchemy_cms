//= require backbone
//= require alchemy/alchemy.spinner
//= require keymaster

Alchemy.Views.PreviewWindow = Backbone.View.extend({
  tagName: 'iframe',
  id: 'alchemy_preview_window',

  defaults: {
    min_width: 240,
    top_menu_height: 75,
    main_menu_width: 150,
    reload_button: '#reload_preview_button',
    size_select: '#preview_size',
    container: 'body'
  },

  initialize(url, options) {
    this.url = url;
    this.options = _.extend({}, this.defaults, options);
    this.$reloadButton = $(this.options.reload_button);
    this.reload_button_html = this.$reloadButton.html();
    this.reload_button_size = {
      width: this.$reloadButton.outerWidth(),
      height: this.$reloadButton.outerHeight()
    };
    this.$sizeSelect = $(this.options.size_select);
    this.$window = $(window);
    this.spinner = new Alchemy.Spinner('small');
    $(this.options.container).append(this.$el);
    this.render().resize()._bindEvents().reload();
  },

  render() {
    this.$el.attr('frameborder', 0);
    this.$el.attr('name', this.id);
    return this;
  },

  resize() {
    let width = this._setWidth('auto');
    let top = this.options.top_menu_height;
    let height = this.$window.height() - top;
    let left = this.options.main_menu_width;
    this.$el.css({top, left, width, height});
    return this;
  },

  reload() {
    this._showSpinner();
    this.$el.attr('src', this.url);
    this.$el.trigger('PreviewWindowReloaded.Alchemy');
    return true;
  },

  _showSpinner() {
    this.$reloadButton.css({
      width: this.reload_button_size.width,
      height: this.reload_button_size.height
    }).html(this.spinner.spin().el);
  },

  _hideSpinner() {
    this.spinner.stop();
    this.$reloadButton.html(this.reload_button_html);
  },

  _bindEvents() {
    this.$el.load(() => this._hideSpinner());
    this.$window.resize(() => this.resize());
    key('alt+r', () => this.reload());
    this.$reloadButton.click(() => this.reload());
    this.$sizeSelect.on('change', (e) => this._setWidth(e.val));
    return this;
  },

  _setWidth(width) {
    if (width === 'auto') {
      width = this._calculateWidth();
    }
    if (width < this.options.min_width) {
      width = this.options.min_width;
    }
    this.width = width;
    this.$el.css('width', width);
  },

  _calculateWidth() {
    let width = this.$window.width() - this.options.main_menu_width;
    if (Alchemy.ElementsWindow && !Alchemy.ElementsWindow.hidden) {
      width -= Alchemy.ElementsWindow.$el.width();
    }
    return width;
  }
});
