//= require vue-2.5.13/vue.js
//= require alchemy/alchemy.spinner
//= require alchemy/alchemy.element_editors

Vue.component('alchemy-preview-window', {
  props: ['url', 'top-menu-height', 'left-menu-width', 'elements-window-width'],
  template: `
    <transition name="fade">
      <iframe :src="url" id="alchemy_preview_window" v-show="visible"/>
    </transition>
  `,

  created() {
    this.min_width = 240;
    Alchemy.eventBus.$on('refresh-preview', (element_id) => {
      this.refresh(() => this.selectElementInPreview(element_id));
    });
    Alchemy.eventBus.$on('resize-preview', this.resize);
    Alchemy.eventBus.$on('SelectElementInPreview', this.selectElementInPreview);
  },

  mounted() {
    this.$reload = $('#reload_preview_button');
    this._bindReloadButton();
    this.$el.onload = this._onLoad;
    this._showSpinner();
    this.visible = true;
  },

  data() {
    return {
      visible: false
    }
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

    selectElementInPreview(element_id) {
      $('#alchemy_preview_window')[0].contentWindow.postMessage({
        message: 'selectAlchemyElement',
        element_id: element_id
      }, window.location.origin);
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
