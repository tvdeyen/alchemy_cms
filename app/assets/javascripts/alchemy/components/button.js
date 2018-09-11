//= require vue-2.5.13/vue.js

// A button with label and icon that opens a link on click
Vue.component('alchemy-button', {
  props: {
    label: {type: String, required: true},
    icon: {type: String, required: true},
    urlMethod: {type: String, default: 'GET'},
    hotkey: String,
    buttonId: String,
    buttonClass: String,
    labelClass: String
  },

  data() {
    return {
      buttonClasses: `button_with_label ${this.buttonClass}`,
      iconClasses: `icon fas fa-fw fa-${this.icon}`
    }
  },

  methods: {
    click(e) {
      e.preventDefault()
      this.$emit('click', e)
    }
  },

  render(h) {
    const icon = h('i', { class: this.iconClasses });
    const label = h('label', { attrs: { class: this.labelClass } }, [this.label])
    const link = h('a', { attrs: {
      class: 'icon_button', 'data-alchemy-hotkey': this.hotkey },
      on: { click: this.click }
    }, [icon]);
    return h('div', { attrs: { class: this.buttonClasses, id: this.buttonId } }, [link, label] )
  }
});
