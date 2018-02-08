//= require alchemy/components/element/save_button

Vue.component('alchemy-element-footer', {
  props: {
    element: {type: Object, required: true}
  },

  template: `
    <div class="element-footer">
      <p class="validation_notice" v-if="element.has_validations">
        <span class="validation_indicator">*</span>
        {{ 'Mandatory' | translate }}
      </p>
      <alchemy-save-element-button :element="element"></alchemy-save-element-button>
    </div>
  `
});
