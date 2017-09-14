//= require backbone
//= require alchemy/models/content
//= require alchemy/templates/essences/essence_richtext
//= require alchemy/alchemy.tinymce

Alchemy.Views.EssenceRichtext = Backbone.View.extend({
  model: Alchemy.Models.Content,
  className: 'essence_richtext content_editor',
  template: HandlebarsTemplates['essences/essence_richtext'],

  initialize() {
    this.content_id = this.model.get('id');
  },

  render() {
    this.$el.html(this.template(this.model.viewAtributes()));
    Alchemy.Tinymce.initEditor(this.content_id);
    this.$el.closest('form').on('submit', ()=> this.update());
  },

  update() {
    let editor = tinymce.get(`tinymce_${this.content_id}`);
    this.model.setEssence('body', editor.getContent());
  }
});
