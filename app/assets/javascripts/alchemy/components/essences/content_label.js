Vue.component('alchemy-content-label', {
  props: {
    content: {type: Object, required: true}
  },

  template: `<label>{{content.label}}</label>`
});
