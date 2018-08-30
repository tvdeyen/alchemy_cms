Vue.component('alchemy-page-external-url', {
  props: { page: Object },
  data() {
    const text = `» Redirects to: ${this.page.external_urlname}`;
    return { text }
  },
  render(h) {
    h('div', { attrs: { class: 'redirect_url' }, title: page.urlname }, [ this.text ])
  }
});
