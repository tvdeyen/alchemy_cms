Vue.component('alchemy-page-link', {
  props: { page: Object },
  render(h) {
    const page = this.page;
    let children = [];
    if (page.permissions.edit_content && !page.redirects_to_external) {
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
        h('span', { attrs: { class: 'sitemap_pagename_link inactive' } }, page.name)
      ]
    }
    return h('div', { attrs: { class: 'sitemap_sitename' } }, children);
  }
});
