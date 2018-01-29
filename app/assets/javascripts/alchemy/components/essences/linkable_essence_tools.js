//= require alchemy/components/icon
//= require alchemy/alchemy.link_dialog
//= require alchemy/alchemy.dirty

Vue.component('alchemy-linkable-essence-tools', {
  props: {
    essence: {type: Object, required: true},
    contentId: {type: Number, required: true}
  },

  template: `
    <span class="linkable_essence_tools">
      <input type="hidden" :value="essence.link"
        :name="link_form_field_name"
        :id="link_form_field_id">
      <input type="hidden" :value="essence.link_title"
        :name="link_title_form_field_name"
        :id="link_title_form_field_id">
      <input type="hidden" :value="essence.link_class_name"
        :name="link_class_name_form_field_name"
        :id="link_class_name_form_field_id">
      <input type="hidden" :value="essence.link_target"
        :name="link_target_form_field_name"
        :id="link_target_form_field_id">
      <a @click.prevent.stop="openLinkDialog" :title="'place_link' | translate" :class="linkCssClasses" :data-content-id="contentId">
        <alchemy-icon name="link"></alchemy-icon>
      </a>
      <a @click.prevent.stop="removeLink" :title="'unlink' | translate" :class="unlinkCssClasses">
        <alchemy-icon name="unlink"></alchemy-icon>
      </a>
    </span>
  `,

  data() {
    const name_prefix = `contents[${this.contentId}]`,
          id_prefix = `contents_${this.contentId}`;

    return {
      link_form_field_name: `${name_prefix}[link]`,
      link_title_form_field_name: `${name_prefix}[link_title]`,
      link_class_name_form_field_name: `${name_prefix}[link_class_name]`,
      link_target_form_field_name: `${name_prefix}[link_target]`,
      link_form_field_id: `${id_prefix}_link`,
      link_title_form_field_id: `${id_prefix}_link_title`,
      link_class_name_form_field_id: `${id_prefix}_link_class_name`,
      link_target_form_field_id: `${id_prefix}_link_target`
    }
  },

  mounted() {
    // The Alchemy.LinkDialog sets the value of the hidden field.
    // As Vue does not watch DOM changes, we need to watch the changes of each field to sync the data.
    // This can probably be refactored if we switch to a data store.
    $(`#${this.link_form_field_id}`).on('change', (e) => {
      this.essence.link = e.currentTarget.value;
    });
    $(`#${this.link_title_form_field_id}`).on('change', (e) => {
      this.essence.link_title = e.currentTarget.value;
    });
    $(`#${this.link_class_name_form_field_id}`).on('change', (e) => {
      this.essence.link_class_name = e.currentTarget.value;
    });
    $(`#${this.link_target_form_field_id}`).on('change', (e) => {
      this.essence.link_target = e.currentTarget.value;
    });
  },

  computed: {
    linkCssClasses() {
      return `icon_button${this.essence.link ? ' linked' : ''} link-essence`;
    },

    unlinkCssClasses() {
      return `icon_button ${this.essence.link ? 'linked' : 'disabled'} unlink-essence`;
    }
  },

  methods: {
    openLinkDialog(e) {
      new Alchemy.LinkDialog(e.currentTarget).open();
    },

    removeLink() {
      if (this.essence.link) {
        Alchemy.setElementDirty($(this.$el).closest('.element-editor'));
      }
      this.essence.link = '';
      this.essence.link_title = '';
      this.essence.link_class_name = '';
      this.essence.link_target = '';
    }
  }
});
