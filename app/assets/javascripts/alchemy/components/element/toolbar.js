//= require alchemy/components/element/toolbar_button

Vue.component('alchemy-element-toolbar', {
  props: {
    element: {type: Object, required: true}
  },

  template: `<div class="element-toolbar">
    <span class="element_tools">
      <alchemy-element-toolbar-button
        :url="copyElementUrl" icon="clone" label="copy_element"
        @requestDone="afterCopyElement">
      </alchemy-element-toolbar-button>
      <alchemy-element-toolbar-button
        :url="cutElementUrl" icon="cut" label="cut_element"
        @requestDone="afterCutElement">
      </alchemy-element-toolbar-button>
      <alchemy-element-toolbar-button
        :url="trashElementUrl" icon="trash-alt"
        label="trash element" method="delete"
        @requestDone="afterTrashElement">
      </alchemy-element-toolbar-button>
      <alchemy-element-toolbar-button
        :url="hideElementUrl" method="patch" icon="eye-slash"
        :label="hideElementLabel"
        @requestDone="afterHideElement">
      </alchemy-element-toolbar-button>
    </span>
  </div>`,

  data() {
    const alchemy = Alchemy.routes,
          id = this.element.id;
    return {
      copyElementUrl: alchemy.copy_admin_element_path(id),
      cutElementUrl: alchemy.cut_admin_element_path(id),
      trashElementUrl: alchemy.trash_admin_element_path(id),
      hideElementUrl: alchemy.publish_admin_element_path(id)
    }
  },

  computed: {
    hideElementLabel() {
      return this.element.public ? 'hide_element' : 'show_element';
    }
  },

  methods: {
    afterCopyElement() {
      let notice = Alchemy.t('item copied to clipboard', this.element.display_name);
      Alchemy.growl(notice);
      $('#clipboard_button .icon').removeClass('fa-clipboard').addClass('fa-paste');
    },

    afterCutElement() {
      let notice = Alchemy.t('item moved to clipboard', this.element.display_name);
      Alchemy.growl(notice);
      this._removeElement();
      $('#clipboard_button .icon').removeClass('fa-clipboard').addClass('fa-paste');
    },

    afterTrashElement() {
      Alchemy.growl(Alchemy.t('Element trashed'));
      this._removeElement();
      Alchemy.TrashWindow.refresh();
      $('#element_trash_button .icon').addClass('full');
      Alchemy.reloadPreview();
    },

    afterHideElement(responseData) {
      this.element.public = responseData.public;
      Alchemy.reloadPreview();
    },

    _removeElement() {
      this.$store.commit('removeElement', {
        parent_id: this.element.parent_element_id,
        element_id: this.element.id
      });
    }
  }
});
