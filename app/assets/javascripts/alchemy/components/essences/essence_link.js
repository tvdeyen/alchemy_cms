//= require alchemy/components/essences/add_link
//= require alchemy/components/essences/remove_link

Vue.component('alchemy-essence-link', {
  props: {
    content: {type: Object, required: true}
  },

  template: `
    <div class="essence_link">
      <alchemy-content-label :content="content"></alchemy-content-label>
      <input type="text" :value="essence.link" class="text_with_icon disabled" disabled>
      <alchemy-content-error :content="content"></alchemy-content-error>
      <span class="linkable_essence_tools">
        <alchemy-add-essence-link
          :essence="essence"
          :content-id="content.id"
          link-class="icon_button"></alchemy-add-essence-link>
        <alchemy-remove-essence-link
          :essence="essence"
          link-class="icon_button"></alchemy-remove-essence-link>
      </span>
    </div>
  `,

  data() {
    return {
      essence: this.content.essence.essence_link
    }
  }
});
