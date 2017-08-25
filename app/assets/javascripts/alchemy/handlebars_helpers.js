//= require handlebars
//= require alchemy/alchemy.i18n

Handlebars.registerHelper("t", function(key, replacement) {
  return Alchemy.t(key, replacement);
});
