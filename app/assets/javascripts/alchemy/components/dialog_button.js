//= require vue-2.5.13/vue.js
//= require alchemy/alchemy.dialog

// A button that opens Alchemy dialog windows
Vue.component('alchemy-dialog-button', {
  props: {
    url: {type: String, required: true},
    label: {type: String, required: true},
    iconClass: {type: String, required: true},
    title: String,
    hotkey: String,
    buttonId: String,
    size: String,
    buttonClass: String,
    labelClass: String
  },

  data() {
    return {
      buttonClasses: `button_with_label ${this.buttonClass}`,
      iconClasses: `icon fas fa-fw fa-${this.iconClass}`
    }
  },

  methods: {
    openDialog(e) {
      e.preventDefault()
      new Alchemy.Dialog(this.url, {
        title: this.title,
        size: this.size
      }).open();
    }
  },

  render(h) {
    const icon = h('i', { class: this.iconClasses });
    const label = h('label', { attrs: { class: this.labelClass } }, [this.label])
    const link = h('a', { attrs: {
      class: 'icon_button', 'data-alchemy-hotkey': this.hotkey },
      on: { click: this.openDialog }
    }, [icon]);
    return h('div', { attrs: { class: this.buttonClasses, id: this.buttonId } }, [link, label] )
  }
});
