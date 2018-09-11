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
    openDialog() {
      new Alchemy.Dialog(this.url, {
        title: this.title,
        size: this.size
      }).open();
    }
  },

  render(h) {
    return h('alchemy-button', {
      props: {
        icon: this.iconClass,
        label: this.label,
        hotkey: this.hotkey,
        labelClass: this.labelClass,
        buttonClass: this.buttonClasses,
        buttonId: this.buttonId
      },
      on: {
        click: this.openDialog
      }
    })
  }
});
