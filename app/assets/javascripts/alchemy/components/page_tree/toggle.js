//= require alchemy/components/spinner

Vue.component('alchemy-page-toggle', {
  props: {
    showSpinner: { type: Boolean, default: false }
  },
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
    const icon = h('i', { class: this.iconClasses })
    const spinner = h('alchemy-spinner', { props: { size: 'small' } })
    return h('a', {
      attrs: { class: 'page_folder' },
      title: this.title,
      on: {
        click: (event) => {
          event.preventDefault();
          this.toggle();
        }
      }
    }, [ this.showSpinner ? spinner : icon ])
  }
});
