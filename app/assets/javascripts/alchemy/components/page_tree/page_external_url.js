Vue.component('alchemy-page-external-url', {
  props: { page: Object },
  data() {
    const page = this.page;
    const text = `» Redirects to: ${page.external_urlname}`;
    const urlname = page.urlname;
    return { text, urlname }
  },
  render(h) {
    h('div', { attrs: { class: 'redirect_url' }, title: this.urlname }, [ this.text ])
  }
});
