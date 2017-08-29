//= require backbone
//= require alchemy/models/content
//= require alchemy/templates/essences/essence_richtext
//= require alchemy/alchemy.tinymce

Alchemy.Views.EssenceRichtext = Backbone.View.extend({
  model: Alchemy.Models.Content,
  className: 'essence_richtext content_editor',
  template: HandlebarsTemplates['essences/essence_richtext'],

  render() {
    let content_id = this.model.get('id');
    this.$el.html(this.template(this.model.viewAtributes()));
    Alchemy.Tinymce.initEditor(content_id);
    let editor = tinymce.get(`tinymce_${content_id}`);
    editor.on('blur', (e) => { this.update(e); });
  },

  update(e) {
    this.model.setEssence('body', e.target.getContent());
  }
});
