Vue.component('alchemy-content-label', {
  props: {
    content: {type: Object, required: true}
  },

  template: `
    <label>
      {{content.label}}
      <span class="validation_indicator" v-if="content.validations.length">*</span>
    </label>
  `
});
