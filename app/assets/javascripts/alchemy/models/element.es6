Alchemy.Models.Element = Backbone.Model.extend({
  urlRoot() {
    return Alchemy.routes.api_elements_path();
  },

  initialize() {
    // Everytime we fold an element we want to persist state on the server
    this.on('change', () => this.save());
    // Everytime we sync the element with server we want the preview to reload
    this.on('sync', (model) => {
      // unless it is was folded/expanded
      if (!_.has(model.changed, 'folded')) {
        Alchemy.PreviewWindow.reload();
      }
    });
  }
});
