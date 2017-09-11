//= require backbone
//= require alchemy/models/element

Alchemy.Collections.Elements = Backbone.Collection.extend({
  model: Alchemy.Models.Element,
  comparator: 'position',

  initialize(page_id) {
    this.page_id = page_id;
  },

  url() {
    return Alchemy.routes.api_elements_path(this.page_id);
  },

  // Alchemy's elements API has a root element, while Backbone expect to not have one
  parse: function(resp, _o) {
    return resp['elements'];
  }
});