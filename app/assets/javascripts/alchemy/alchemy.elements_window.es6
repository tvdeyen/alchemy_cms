//= require vue-2.5.13/vue.js
//= require alchemy/alchemy.spinner
//= require alchemy/alchemy.gui
//= require alchemy/alchemy.base
//= require alchemy/alchemy.element_editors
//= require alchemy/alchemy.dirty
//= require alchemy/alchemy.dragndrop
//= require alchemy/alchemy.tinymce

Vue.component('alchemy-elements-window', {
  props: {
    url: {type: String, required: true},
    pageId: {type: Number, required: true},
    topMenuHeight: String,
    richtextContentIds: Array
  },

  template: `
  <div id="alchemy_elements_window">
    <div id="elements_toolbar">
      <alchemy-dialog-button url="/admin/elements/new?page_id=3"
        label="New Element" title="New Element"
        icon-class="plus" hotkey="alt+n" size="320x125" />
      <alchemy-dialog-button url="/admin/clipboard/elements"
        label="Show Clipboard" title="Clipboard"
        icon-class="clipboard" hotkey="alt+v" />
      <alchemy-dialog-button url="/admin/trash"
        label="Show Trash" title="Trash"
        icon-class="trash-alt" />
    </div>
    <div id="element_area"></div>
  </div>`,

  created() {
    this.hidden = false;
    Alchemy.eventBus.$on('resize-elements-window', this.resize);
  },

  mounted() {
    this.$elements_window = $(this.$el);
    this.$element_toolbar = $('#elements_toolbar');
    this.$element_area = $('#element_area');
    this.$button = $('#element_window_button');
    this.$button.click(e => {
      e.preventDefault();
      this.toggle();
    });
    this.resize();
    this.reload();
  },

  methods: {
    resize() {
      let height = $(window).height() - this.topMenuHeight;
      this.$element_area.css({
        height: height - this.$element_toolbar.outerHeight()
      });
    },

    reload() {
      let spinner = new Alchemy.Spinner('medium');
      spinner.spin(this.$element_area[0]);
      $.get(this.url, (data) => {
        this.$element_area.html(data);
        Alchemy.GUI.init(this.$element_area);
        Alchemy.ElementEditors.init();
        Alchemy.ImageLoader(this.$element_area);
        Alchemy.ElementDirtyObserver(this.$element_area);
        Alchemy.Tinymce.init(this.richtextContentIds);
        $('#cells').tabs().tabs('paging', {
          follow: true,
          followOnSelect: true
        });
        Alchemy.SortableElements(this.pageId);
      }).fail((xhr, status, error) => {
        Alchemy.AjaxErrorHandler(this.$element_area, xhr.status, status, error);
      }).always(() => spinner.stop());
    },

    toggle() {
      if (this.hidden) {
        this.show();
      } else {
        this.hide();
      }
      Alchemy.elementWindowHidden = this.hidden;
      Alchemy.resizePreview();
      this.toggleButton();
    },

    hide() {
      this.$elements_window.css('right', -400);
      this.hidden = true;
    },

    show() {
      this.$elements_window.css('right', 0);
      this.hidden = false;
    },

    toggleButton() {
      if (this.hidden) {
        this.$button.find('label').text('Show elements');
      } else {
        this.$button.find('label').text('Hide elements');
      }
    }
  }
});

Alchemy.resizeElementsWindow = function() {
  Alchemy.eventBus.$emit('resize-elements-window');
}
