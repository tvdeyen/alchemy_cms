//= require backbone
//= require alchemy/models/content
//= require alchemy/templates/essences/essence_picture

Alchemy.Views.EssencePicture = Backbone.View.extend({
  model: Alchemy.Models.Content,
  className: 'essence_picture_editor content_editor',
  template: HandlebarsTemplates['essences/essence_picture'],

  render() {
    this.$el.html(this.template(this.model.viewAtributes()));
  }
});
