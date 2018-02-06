//= require vue-2.5.13/vue.js
//= require alchemy/alchemy.spinner
//= require alchemy/alchemy.base
//= require alchemy/alchemy.dragndrop
//= require alchemy/alchemy.i18n
//= require alchemy/alchemy.vue_filters
//= require alchemy/components/element_editor

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
      <alchemy-dialog-button :url="newElementUrl"
        :label="'New Element' | translate" :title="'New Element' | translate"
        icon-class="plus" hotkey="alt+n" size="320x125" />
      <alchemy-dialog-button :url="clipboardUrl"
        :label="'Show clipboard' | translate" :title="'Clipboard' | translate"
        icon-class="clipboard" hotkey="alt+v" id="clipboard_button" />
      <div class="button_with_label" id="element_trash_button">
        <a class="icon_button" @click.prevent="openTrashWindow">
          <i class="icon fas fa-trash-alt fa-fw"></i>
        </a>
        <label>{{ 'Show trash' | translate }}</label>
      </div>
    </div>
    <div id="element_area">
      <div class="sortable_cell">
        <alchemy-element-editor v-for="element in elements"
          :key="element.id"
          :element="element"
        ></alchemy-element-editor>
      </div>
    </div>
  </div>`,

  data() {
    const alchemy = Alchemy.routes;
    return {
      newElementUrl: alchemy.new_admin_element_path(this.pageId),
      clipboardUrl: alchemy.admin_clipboard_path('elements')
    }
  },

  created() {
    this.hidden = false;
  },

  mounted() {
    this.$body = $('body');
    this.$elements_window = $(this.$el);
    this.$element_toolbar = $('#elements_toolbar');
    this.$element_area = $('#element_area');
    this.$button = $('#element_window_button');
    this.$button.click(e => {
      e.preventDefault();
      this.toggle();
    });
    // Blur selected elements
    $('body').click(e => {
      let element = $(e.target).parents('.element-editor')[0];
      // Not passing an element id here actually unselects all elements
      this.$store.commit('selectElement');
      if (!element) {
        let frameWindow = $('#alchemy_preview_window')[0].contentWindow;
        frameWindow.postMessage({message: 'blurAlchemyElements'}, window.location.origin);
      }
    });
    this.show();
    this.load();
  },

  computed: {
    elements() {
      return this.$store.state.elements;
    }
  },

  methods: {
    resize() {
      let height = $(window).height() - this.topMenuHeight;
      this.$element_area.css({
        height: height - this.$element_toolbar.outerHeight()
      });
    },

    load() {
      let spinner = new Alchemy.Spinner('medium');
      spinner.spin(this.$element_area[0]);
      $.getJSON(this.url, (responseData) => {
        // Unselect all elements so that we can use this state in the Vuex store
        function unselectElements(elements) {
          for (let element of elements) {
            element.selected = false;
            unselectElements(element.nested_elements);
          };
        }
        unselectElements(responseData.elements);
        this.$store.replaceState({elements: responseData.elements});
        // $('#cells').tabs().tabs('paging', {
        //   follow: true,
        //   followOnSelect: true,
        //   prevButton: '<i class="fas fa-angle-double-left"></i>',
        //   nextButton: '<i class="fas fa-angle-double-right"></i>'
        // });
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
      this.toggleButton();
    },

    hide() {
      this.$body.removeClass('elements-window-visible');
      this.hidden = true;
    },

    show() {
      this.$body.addClass('elements-window-visible');
      this.hidden = false;
    },

    toggleButton() {
      if (this.hidden) {
        this.$button.find('label').text('Show elements');
      } else {
        this.$button.find('label').text('Hide elements');
      }
    },

    openTrashWindow() {
      Alchemy.TrashWindow.open(this.pageId, Alchemy.t('Trash'));
    }
  }
});
