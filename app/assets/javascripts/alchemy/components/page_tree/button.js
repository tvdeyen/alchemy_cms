//= require alchemy/components/dialog_button

Vue.component('alchemy-sitemap-button', {
  props: {
    url: String,
    icon: String,
    label: String,
    disabled: { type: Boolean, default: false },
    disabledNotice: String,
    dialog: Object
  },
  data() {
    return {
      iconClasses: `icon fa-fw fas fa-${this.icon}`
    }
  },
  render(h) {
    const icon = h('i', { class: this.iconClasses });
    if (this.disabled) {
      return h('div', { attrs: { class: 'disabled with-hint sitemap_tool' } }, [
        icon,
        h('span', { attrs: { class: 'hint-bubble' } }, this.disabledNotice)
      ])
    }
    if (this.dialog) {
      return h('alchemy-dialog-button', {
        props: {
          iconClass: this.icon,
          url: this.url,
          label: this.label,
          title: this.dialog.title,
          size: this.dialog.size,
          buttonClass: 'sitemap_tool',
          labelClass: 'center'
        }
      })
    }
  }
});
