function handleVueDestructionOn(turbolinksEvent, vue) {
  document.addEventListener(turbolinksEvent, function teardown() {
    vue.$destroy();
    document.removeEventListener(turbolinksEvent, teardown);
  });
}

var TurbolinksAdapter = {
  beforeMount: function() {
    // If this is the root component, we want to cache the original element contents to replace later
    // We don't care about sub-components, just the root
    if (this == this.$root) {
      handleVueDestructionOn('turbolinks:visit', this);
      this.$originalEl = this.$el.outerHTML;
    }
  },

  destroyed: function() {
    // We only need to revert the html for the root component
    if (this == this.$root && this.$el) {
      this.$el.outerHTML = this.$originalEl;
    }
  }
};
