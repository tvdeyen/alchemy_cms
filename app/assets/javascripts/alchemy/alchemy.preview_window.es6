//= require vue-2.5.13/vue.js
//= require alchemy/alchemy.spinner
//= require alchemy/alchemy.element_editors

Vue.component('alchemy-preview-window', {
  props: ['url', 'top-menu-height', 'left-menu-width', 'elements-window-width'],
  template: '<iframe :src="url" id="alchemy_preview_window"/>',

  created() {
    this.min_width = 240;
    Alchemy.eventBus.$on('refresh-preview', (element_id) => {
      this.refresh(function() {
        Alchemy.ElementEditors.selectElementInPreview(`${element_id}`);
      });
    });
    Alchemy.eventBus.$on('resize-preview', this.resize);
  },

  mounted() {
    this.$reload = $('#reload_preview_button');
    this._bindReloadButton();
    this.$el.onload = this._onLoad;
    this._showSpinner();
  },

  methods: {
    resize(width) {
      if (width < this.minWidth) width = this.minWidth;
      $(this.$el).css({width: width});
    },

    refresh(callback) {
      let $iframe = $(this.$el);
      $iframe.off('load').on('load', () => {
        this._onLoad();
        if (callback) callback.call();
      });
      this._showSpinner();
      $iframe.attr('src', this.url);
      return true;
    },

    // private

    _showSpinner() {
      this.spinner = new Alchemy.Spinner('small');
      this.$reload.find('.icon').hide();
      this.spinner.spin(this.$reload[0]);
    },

    _hideSpinner() {
      this.spinner.stop();
      this.$reload.find('.icon').show();
    },

    _onLoad() {
      this._hideSpinner();
    },

    _bindReloadButton() {
      key('alt+r', () => this.refresh());
      this.$reload.on('click', e => {
        e.preventDefault();
        this.refresh();
      });
    }
  }
});

Alchemy.reloadPreview = function(element_id) {
  Alchemy.eventBus.$emit('refresh-preview', element_id);
};

Alchemy.resizePreview = function(size) {
  Alchemy.eventBus.$emit('resize-preview', size);
};
