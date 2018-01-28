Vue.component('alchemy-element-footer', {
  props: {
    element: {type: Object, required: true}
  },

  template: `
    <div class="element-footer">
      <p class="validation_notice" v-if="validations.length">
        <span class="validation_indicator">*</span>
        {{ 'Mandatory' | translate }}
      </p>

      <button @click="save" type="submit" class="button" data-alchemy-button>
        {{ 'save' | translate }}
      </button>
    </div>
  `,

  data() {
    return {
      validations: []
    }
  },

  methods: {
    save() {
      return true;
    }
  }
});
