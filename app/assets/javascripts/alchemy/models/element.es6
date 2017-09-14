Alchemy.Models.Element = Backbone.Model.extend({
  urlRoot() {
    return Alchemy.routes.api_elements_path();
  },

  initialize() {
    // Everytime we fold an element we want to persist state on the server
    this.on('change', () => this.save());
  }
});
