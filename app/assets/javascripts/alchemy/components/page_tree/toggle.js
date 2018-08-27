Vue.component('alchemy-page-toggle', {
  props: { page: Object },
  render(h) {
    const page = this.page
    const iconClasses = ['far', 'fa-fw']
    iconClasses.push(page.folded ? 'fa-plus-square' : 'fa-minus-square')
    return h('a', {
      href: `/admin/pages/${page.id}/fold`,
      attrs: { class: 'page_folder' },
      title: page.folded ? 'Show childpages' : 'Hide childpages'
    }, [
      h('i', { class: iconClasses })
    ])
  }
});
