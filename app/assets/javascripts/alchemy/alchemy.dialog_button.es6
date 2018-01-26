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
    size: String
  },

  template: `<div class="button_with_label" :id="buttonId">
    <a :title="title" @click.prevent="openDialog" class="icon_button" :data-alchemy-hotkey="hotkey">
      <i :class="iconClasses"></i>
    </a><br>
    <label>{{label}}</label>
  </div>`,

  data() {
    return {
      iconClasses: `icon fas fa-fw fa-${this.iconClass}`
    }
  },

  methods: {
    openDialog(e) {
      new Alchemy.Dialog(this.url, {
        title: this.title,
        size: this.size
      }).open();
    }
  }
});
