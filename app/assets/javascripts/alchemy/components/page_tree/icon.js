Vue.component('alchemy-page-icon', {
  props: { page: Object },
  render(h) {
    const page = this.page;
    const iconClasses = page.locked ? 'icon fas fa-edit fa-fw' : 'icon far fa-file fa-lg';
    const icon = h('i', { class: iconClasses });
    if (page.locked) {
      return h('span', { attrs: { class: 'with-hint' } }, [
        icon,
        h('span', { attrs: { class: 'hint-bubble' } }, page.locked_notice)
      ]);
    } else {
      return icon;
    }
  }
});
