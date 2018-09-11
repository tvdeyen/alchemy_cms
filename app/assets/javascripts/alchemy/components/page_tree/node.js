//= require vue-2.5.13/vue.js
//= require alchemy/components/page_tree/page_link
//= require alchemy/components/page_tree/page_status
//= require alchemy/components/page_tree/page_external_url
//= require alchemy/components/page_tree/toggle
//= require alchemy/components/page_tree/button

Vue.component('alchemy-page-node', {
  props: {
    page: { type: Object, required: true }
  },
  data() {
    return {
      children: this.page.children
    }
  },
  methods: {
    toggle(data) {
      if (data.folded) {
        this.children = []
      } else {
        $.getJSON('/admin/pages/tree', { id: this.page.id }, (data) => {
          this.children = data
        })
      }
    }
  },
  render(h) {
    const page = this.page;

    const nodes = [
      h('div', { attrs: { class: 'sitemap_right_tools' } }, [
        h('alchemy-sitemap-button', {
          props: {
            icon: 'info-circle',
            url: `/admin/pages/${page.id}/info`,
            label: 'Page info',
            dialog: {
              title: 'Page info',
              size: '520x290'
            },
            disabled: !page.permissions.info,
            disabledNotice: 'Your user role does not allow you to see info about this page'
          }
        }),
        h('alchemy-sitemap-button', {
          props: {
            icon: 'cog',
            url: `/admin/pages/${page.id}/configure`,
            label: 'Edit page properties',
            dialog: {
              title: 'Edit page properties',
              size: page.redirects_to_external ? '450x330' : '450x680'
            },
            disabled: !page.permissions.configure,
            disabledNotice: 'Your user role does not allow you to edit this pages properties'
          }
        }),
        h('alchemy-sitemap-button', {
          props: {
            icon: 'copy',
            url: Alchemy.routes.copy_admin_page_path(page.id),
            urlMethod: 'POST',
            label: 'Copy page',
            disabled: !page.permissions.copy,
            disabledNotice: 'Your user role does not allow you to edit this pages content'
          }
        }),
        h('alchemy-sitemap-button', {
          props: {
            icon: 'minus',
            url: `/admin/pages/${page.id}`,
            urlMethod: 'DELETE',
            label: 'Delete this page',
            confirm: {
              message: 'Do you really want to delete this page?',
            },
            disabled: !page.permissions.destroy,
            disabledNotice: 'Your user role does not allow you to delete this page'
          }
        }),
        h('alchemy-sitemap-button', {
          props: {
            icon: 'plus',
            url: `/admin/pages/new?parent_id=${page.id}`,
            label: 'Create a new subpage',
            dialog: {
              title: 'Create a new subpage',
              size: '340x165'
            },
            disabled: !page.permissions.create,
            disabledNotice: 'Your user role does not allow you to create a new subpage'
          }
        })
      ]),

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
      leftImages.unshift(h('alchemy-page-toggle', { on: { toggle: this.toggle } }))
    }
    nodes.push(h('div', { attrs: { class: 'sitemap_left_images' } }, leftImages))

    if (page.redirects_to_external) {
      nodes.push(h('alchemy-page-external-url', { props: { page } }))
    }

    nodes.push(h('alchemy-page-link', { props: { page } }))

    if (this.children.length) {
      nodes.push(h('ul', this.children.map((child) => {
        Object.assign(child, { children: [] })
        return h('alchemy-page-node', { props: { page: child } })
      })))
    }

    return h('li', { attrs: { class: 'sitemap_page' } }, nodes)
  }
});
