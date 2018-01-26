//= require vue-2.5.13/vue.js
//= require alchemy/alchemy.i18n.js

Vue.filter('translate', function (value, replacement) {
  if (!value) return '';
  return Alchemy.t(value, replacement);
});
