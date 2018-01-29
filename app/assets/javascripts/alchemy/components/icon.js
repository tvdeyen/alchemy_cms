Vue.component('alchemy-icon', {
  props: {
    name: {type: String, required: true},
    iconStyle: String
  },

  template: '<i :class="cssClasses"></i>',

  data() {
    let style = this.iconStyle === 'regular' ? 'far' : 'fas';
    return {
      cssClasses: `icon faw ${style} fa-${this.name}`
    }
  }
});
