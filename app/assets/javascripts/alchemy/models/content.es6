//= require backbone

Alchemy.Models.Content = Backbone.Model.extend({
  urlRoot: Alchemy.routes.api_contents_path,

  initialize(attributes, element) {
    // Belongs to element
    this.element = element;
    this.attributes = attributes;
    this.essence_type = this.attributes.essence.type;
  },

  // Sets the ingredient value used by the view
  // as well as the nested essence that gets persisted by the server
  setEssence(column, value) {
    this.set('ingredient', value);
    this.get('essence')[this.essence_type][column] = value;
  },

  // Normalized attributes for the view
  viewAtributes() {
    return {
      id: this.attributes.id,
      label: this.attributes.label,
      settings: this.attributes.settings,
      ingredient: this.attributes.ingredient,
      essence: this.attributes.essence[this.essence_type]
    }
  }
});
