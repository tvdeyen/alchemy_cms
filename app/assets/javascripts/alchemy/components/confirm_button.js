//= require vue-2.5.13/vue.js
//= require alchemy/alchemy.confirm_dialog

// A button that opens a Alchemy confirm dialog
Vue.component('alchemy-confirm-button', {
  props: {
    url: {type: String, required: true},
    message: {type: String, required: true},
    icon: {type: String, required: true},
    urlMethod: {type: String, default: 'POST'},
    label: String,
    labelClass: String,
    buttonClass: String,
    title: String
  },

  data() {
    return {
      buttonClasses: `button_with_label ${this.buttonClass}`,
      iconClasses: `icon fas fa-fw fa-${this.icon}`
    }
  },

  methods: {
    confirm() {
      $.ajax(this.url, { method: this.urlMethod })
    },
    openDialog(e) {
      e.preventDefault()
      Alchemy.openConfirmDialog(this.message, {
        title: this.title,
        ok_label: Alchemy.t('ok'),
        cancel_label: Alchemy.t('cancel'),
        on_ok: this.confirm
      });
    }
  },

  render(h) {
    return h('div', { attrs: { class: this.buttonClasses } }, [
      h('a', {
        attrs: { class: 'icon_button' },
        on: { click: this.openDialog }
      }, [
        h('i', { class: this.iconClasses })
      ]),
      h('label', { attrs: { class: this.labelClasses } }, [this.label] )
    ])
  }
});
