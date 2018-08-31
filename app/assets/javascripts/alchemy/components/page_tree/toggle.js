Vue.component('alchemy-page-toggle', {
  data() {
    return { folded: true }
  },
  computed: {
    iconClasses() {
      const iconClasses = ['far', 'fa-fw']
      iconClasses.push(this.folded ? 'fa-plus-square' : 'fa-minus-square')
      return iconClasses
    },
    title() {
      return this.folded ? 'Show childpages' : 'Hide childpages';
    }
  },
  methods: {
    toggle() {
      this.folded = !this.folded;
      this.$emit('toggle', { folded: this.folded});
    }
  },
  render(h) {
    return h('a', {
      attrs: { class: 'page_folder' },
      title: this.title,
      on: {
        click: (event) => {
          event.preventDefault();
          this.toggle();
        }
      }
    }, [ h('i', { class: this.iconClasses }) ])
  }
});
