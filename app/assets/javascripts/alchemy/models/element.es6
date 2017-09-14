Alchemy.Models.Element = Backbone.Model.extend({
  urlRoot() {
    return Alchemy.routes.api_elements_path();
  }
});
