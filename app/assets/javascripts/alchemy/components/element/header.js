//= require alchemy/components/element/toggle_button

Vue.component('alchemy-element-header', {
  props: {
    element: {type: Object, required: true}
  },

  template: `
    <div class="element-header">
      <span class="element-handle">
        <i :class="iconClasses"></i>
      </span>
      <span class="element-title">
        <span class="preview_text_element_name">{{element.display_name}}</span>
        <span class="preview_text_quote">{{quote}}</span>
      </span>
      <alchemy-toggle-element-button :element="element"></alchemy-toggle-element-button>
    </div>
  `,

  created() {
    this.QUOTE_MAX_LENGTH = 30;
  },

  data() {
    return {
      preview_content: this.element.contents[0]
    }
  },

  computed: {
    quote() {
      if (!this.preview_content) return '';
      let quote = this.preview_content.ingredient;
      if (quote.length > this.QUOTE_MAX_LENGTH) {
        return `${quote.substring(0, this.QUOTE_MAX_LENGTH - 1)}…`;
      } else {
        return quote;
      }
    },

    iconClasses() {
      const icon = this.element.public ? 'maximize far' : 'close fas';
      return `fa-fw fa-window-${icon}`;
    }
  }
});
