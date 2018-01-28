//= require vue-2.5.13/vue.js
//= require alchemy/components/element/header
//= require alchemy/components/element/toolbar
//= require alchemy/components/element/footer

Vue.component('alchemy-element-editor', {
  props: {
    element: {type: Object, required: true}
  },

  template: `
    <div :id="elementId" :data-element-id="element.id" :data-element-name="element.name" :class="cssClasses">
      <alchemy-element-header :element="element"></alchemy-element-header>
      <template v-if="!element.folded">
        <alchemy-element-toolbar :element="element"></alchemy-element-toolbar>
        <div class="element-content"></div>
        <alchemy-element-footer :element="element"></alchemy-element-footer>
      </template>
    </div>
  `,

  data() {
    const element = this.element;
    return {
      elementId: `element_${element.id}`
    }
  },

  computed: {
    cssClasses() {
      let classes = ['element-editor', 'draggable'];
      classes.push(this.element.contents.length ? 'with-contents' : 'without-contents');
      classes.push(this.element.nestable_elements.length ? 'nestable' : 'not-nestable');
      classes.push(this.element.taggable ? 'taggable' : 'not-taggable');
      classes.push(this.element.folded ? 'folded' : 'expanded');
      return classes.join(' ');
    }
  }
});
