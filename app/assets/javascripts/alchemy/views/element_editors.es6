Alchemy.Views = Alchemy.Views || {};

Alchemy.Views.ElementEditors = Backbone.View.extend({
  el: '#element_area > .sortable_cell',

  render() {
    _.each(this.collection.models, (model) => {
      let view = new Alchemy.Views.Element({model});
      view.$el.appendTo(this.$el);
      view.render();
    });
  }
});
