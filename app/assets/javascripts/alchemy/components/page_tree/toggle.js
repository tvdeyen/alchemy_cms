Vue.component('alchemy-page-toggle', {
  props: { page: Object },
  data() {
    const page = this.page;
    const iconClasses = ['far', 'fa-fw']
    const title = page.folded ? 'Show childpages' : 'Hide childpages';
    iconClasses.push(page.folded ? 'fa-plus-square' : 'fa-minus-square')
    return { iconClasses, title }
  },
  render(h) {
    return h('a', {
      attrs: { class: 'page_folder' },
      title: this.title,
      on: {
        click: (event) => {
          $.getJSON('/admin/pages/tree', { id: this.page.id }, (data) => {
            console.log(data)
          });
          event.preventDefault();
        }
      }
    }, [ h('i', { class: this.iconClasses }) ])
  }
});
