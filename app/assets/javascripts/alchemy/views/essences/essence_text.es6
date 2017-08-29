//= require backbone
//= require alchemy/models/content
//= require alchemy/templates/essences/essence_text
//= require alchemy/alchemy.link_dialog

Alchemy.Views.EssenceText = Backbone.View.extend({
  model: Alchemy.Models.Content,
  className: 'essence_text content_editor',
  template: HandlebarsTemplates['essences/essence_text'],

  events: {
    'click .link-essence': 'link',
    'click .unlink-essence': 'unlink'
  },

  render() {
    this.$el.html(this.template(this.model.viewAtributes()));
  },

  link(e) {
    new Alchemy.LinkDialog(e.target.parentNode).open();
    return false;
  },

  unlink(e) {
    Alchemy.LinkDialog.removeLink(e.target.parentNode, this.model.get('id'));
    return false;
  }
});
