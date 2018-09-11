//= require alchemy/components/dialog_button
//= require alchemy/components/confirm_button

Vue.component('alchemy-sitemap-button', {
  props: {
    url: String,
    urlMethod: String,
    icon: String,
    label: String,
    disabled: { type: Boolean, default: false },
    disabledNotice: String,
    dialog: Object,
    confirm: Object
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
    if (this.confirm) {
      return h('alchemy-confirm-button', {
        props: {
          url: this.url,
          urlMethod: this.urlMethod,
          icon: this.icon,
          label: this.label,
          message: this.confirm.message,
          buttonClass: 'sitemap_tool',
          labelClass: 'center'
        }
      })
    }
  }
});
