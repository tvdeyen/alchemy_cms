Vue.component('alchemy-page-status', {
  props: {
    icon: String,
    hint: String,
    disabled: Boolean
  },
  render(h) {
    const iconClasses = ['icon', 'fas', 'fa-fw', `fa-${this.icon}`];
    if (this.disabled) iconClasses.push('disabled') ;
    return h('span', { attrs: { class: 'page_status with-hint' } }, [
      h('i', { class: iconClasses }),
      h('span', { attrs: { class: 'hint-bubble' } }, this.hint)
    ]);
  }
});
