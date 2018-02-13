//= require alchemy/components/essences/content_label
//= require alchemy/components/essences/essence_picture
//= require alchemy/components/essences/essence_text
//= require alchemy/components/essences/essence_html
//= require alchemy/components/essences/essence_date
//= require alchemy/components/essences/essence_boolean
//= require alchemy/components/essences/essence_select
//= require alchemy/components/essences/essence_link
//= require alchemy/components/essences/essence_file
//= require alchemy/components/essences/essence_richtext

Vue.component('alchemy-content-editor', {
  props: {
    content: {type: Object, required: true},
  },

  template: `<div
    :is="content.component_name"
    :content="content"
    :data-content-id="content.id"
    :class="cssClasses">
  </div>`,

  computed: {
    cssClasses() {
      return 'content_editor';
    }
  }
});
