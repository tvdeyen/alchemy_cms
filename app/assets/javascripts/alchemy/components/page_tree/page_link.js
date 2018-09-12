Vue.component('alchemy-page-link', {
  props: {
    page: Object,
    disabled: { type: Boolean, default: false }
  },
  data() {
    const page = this.page;
    return {
      active: page.permissions.edit_content && !page.redirects_to_external && !this.disabled
    }
  },
  methods: {
    click(e) {
      const linkDialog = Alchemy.currentDialog()
      if (linkDialog) {
        linkDialog.dialog_body.trigger('page_selected', {
          page_id: this.page.id,
          url: this.page.urlname
        })
      }
      e.preventDefault()
    }
  },
  render(h) {
    const page = this.page;
    let children = [];
    if (this.active) {
      children = [
        h('a', {
          attrs: {
            href: Alchemy.routes.edit_admin_page_path(page.id),
            class: 'sitemap_pagename_link'
          }
        }, page.name)
      ]
    } else {
      children = [
        h('span', {
          attrs: { class: 'sitemap_pagename_link inactive' },
          on: { click: this.click }
        }, page.name)
      ]
    }
    return h('div', { attrs: { class: 'sitemap_sitename', id: `sitemap_sitename_${page.id}` } }, children);
  }
});
