//= require vue-2.5.13/vue.js
//= require alchemy/components/element/header
//= require alchemy/components/element/toolbar
//= require alchemy/components/element/footer
//= require alchemy/components/content_editor
//= require alchemy/alchemy.i18n
//= require alchemy/alchemy.dialog
//= require alchemy/alchemy.dragndrop

Vue.component('alchemy-element-editor', {
  props: {
    element: {type: Object, required: true}
  },

  template: `
    <div :id="elementId" :data-element-id="element.id" :data-element-name="element.name" :class="cssClasses" @click.stop="focusElement">
      <alchemy-element-header :element="element"></alchemy-element-header>
      <template v-if="!element.folded">
        <alchemy-element-toolbar :element="element"></alchemy-element-toolbar>
        <form class="element-content" :id="formId" v-if="contents.length">
          <alchemy-content-editor v-for="content in contents"
            :key="content.id"
            :content="content"></alchemy-content-editor>
        </form>
        <alchemy-element-footer :element="element" v-if="contents.length"></alchemy-element-footer>
        <div class="nestable-elements" v-if="nestedElements.length">
          <div class="nested-elements">
            <alchemy-element-editor v-for="element in nestedElements"
              :key="element.id"
              :element="element"></alchemy-element-editor>
          </div>
          <a @click.prevent="newElement" class="button with_icon add-nestable-element-button">
            <i class="icon fas fa-plus fa-fw fa-xs"></i>
            {{ 'New Element' | translate }}
          </a>
        </div>
      </template>
    </div>
  `,

  mounted() {
    Alchemy.SortableElements(this.element.page_id, `#${this.elementId} .nested-elements`);
  },

  computed: {
    contents() {
      return this.element.contents;
    },

    nestedElements() {
      return this.element.nested_elements;
    },

    elementId() {
      return `element_${this.element.id}`;
    },

    formId() {
      return `element_${this.element.id}_form`;
    },

    cssClasses() {
      let classes = ['element-editor', 'draggable'];
      classes.push(this.element.contents.length ? 'with-contents' : 'without-contents');
      classes.push(this.element.nestable_elements.length ? 'nestable' : 'not-nestable');
      classes.push(this.element.taggable ? 'taggable' : 'not-taggable');
      classes.push(this.element.folded ? 'folded' : 'expanded');
      classes.push(this.element.selected ? 'selected' : '');
      return classes.join(' ');
    }
  },

  methods: {
    newElement() {
      let url = Alchemy.routes.new_admin_element_path(
        this.element.page_id,
        this.element.id
      );
      Alchemy.openDialog(url, {
        size: "320x125",
        title: Alchemy.t("New Element")
      });
    },

    focusElement(e) {
      this.$store.commit('selectElement', this.element.id);
    }
  }
});
