//= require backbone
//= require alchemy/models/content

Alchemy.Collections.Contents = Backbone.Collection.extend({
  model: Alchemy.Models.Content,
  url: Alchemy.routes.api_batch_contents_path,
  comparator: 'position',

  save: function() {
    let options = {
      success: (data) => {
        this.trigger('sync', this, data);
      }
    };
    return this.sync('patch', this, options);
  }
});
