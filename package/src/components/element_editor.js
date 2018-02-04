import AlchemyContentEditor from "./content_editor"
import AlchemyElementHeader from "./element/header"
import AlchemyElementToolbar from "./element/toolbar"
import AlchemyElementFooter from "./element/footer"

export default {
  props: {
    element: { type: Object, required: true }
  },

  template: `
    <div :id="elementId" :data-element-id="element.id" :data-element-name="element.name" :class="cssClasses">
      <alchemy-element-header :element="element"></alchemy-element-header>
      <template v-if="!element.folded">
        <alchemy-element-toolbar :element="element"></alchemy-element-toolbar>
        <template v-if="contents.length">
          <form class="element-content" :id="formId">
            <alchemy-content-editor v-for="content in contents"
              :key="content.id"
              :content="content"></alchemy-content-editor>
          </form>
          <alchemy-element-footer :element="element"></alchemy-element-footer>
        </template>
        <div class="nestable-elements" v-if="nestedElements.length">
          <div class="nested-elements">
            <alchemy-element-editor v-for="element in nestedElements"
              :key="element.id"
              :element="element"></alchemy-element-editor>
          </div>
          <a @click.prevent="newElement" class="button with_icon add-nestable-element-button">
            {{ 'New Element' | translate }}
          </a>
        </div>
      </template>
    </div>
  `,

  components: {
    AlchemyContentEditor,
    AlchemyElementHeader,
    AlchemyElementToolbar,
    AlchemyElementFooter,
    AlchemyElementEditor: () => import("./element_editor.js")
  },

  data() {
    const element = this.element
    return {
      elementId: `element_${element.id}`,
      formId: `element_${element.id}_form`,
      contents: element.contents,
      nestedElements: element.nested_elements
    }
  },

  computed: {
    cssClasses() {
      let classes = ["element-editor"]

      classes.push(
        this.element.contents.length ? "with-contents" : "without-contents"
      )
      classes.push(
        this.element.nestable_elements.length ? "nestable" : "not-nestable"
      )
      classes.push(this.element.taggable ? "taggable" : "not-taggable")
      classes.push(this.element.folded ? "folded" : "expanded")
      if (this.element.compact) classes.push("compact")
      if (this.element.deprecated) classes.push("deprecated")
      classes.push(this.element.fixed ? "fixed" : "not-fixed")
      classes.push(this.element.public ? "visible" : "hidden")

      return classes.join(" ")
    }
  },

  methods: {
    newElement() {
      const url = Alchemy.routes.new_admin_element_path(
        this.element.page_id,
        this.element.id
      )
      Alchemy.openDialog(url, {
        size: "320x125",
        title: Alchemy.t("New Element")
      })
    }
  }
}