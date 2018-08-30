//= require vue-2.5.13/vue.js
//= require alchemy/components/page_tree/page_link
//= require alchemy/components/page_tree/page_status
//= require alchemy/components/page_tree/page_external_url
//= require alchemy/components/page_tree/toggle

Vue.component('alchemy-page-node', {
  props: {
    page: { type: Object, required: true }
  },
  data() {
    const page = this.page
    const pageClasses = ['sitemap_page']
    const leftPadding = (page.level - 1) * 32;
    const pageStyle = { paddingLeft: `${leftPadding}px` }
    if (page.locked) pageClasses.push('locked')
    return { pageClasses, pageStyle }
  },
  render(h) {
    const page = this.page;
    const nodes = [
      h('div', { attrs: { class: 'page_infos' } }, [
        h('alchemy-page-status', {
          props: { hint: page.status_titles.public, icon: 'compass', disabled: !page.public }
        }),
        h('alchemy-page-status', {
          props: { hint: page.status_titles.visible, icon: 'eye', disabled: !page.visible }
        }),
        h('alchemy-page-status', {
          props: { hint: page.status_titles.restricted, icon: 'lock', disabled: !page.restricted }
        })
      ])
    ]
    const leftImages = [h('alchemy-page-icon', { props: { page } })];
    if (page.has_children && !page.root) {
      leftImages.unshift(h('alchemy-page-toggle', { props: { page } }))
    }
    nodes.push(h('div', { attrs: { class: 'sitemap_left_images' } }, leftImages))
    if (page.redirects_to_external) {
      nodes.push(h('alchemy-page-external-url', { props: { page } }))
    }
    nodes.push(h('alchemy-page-link', { props: { page } }))
    return h('li', { class: this.pageClasses, style: this.pageStyle }, nodes)
  }
});
