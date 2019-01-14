const { environment } = require('@rails/webpacker')
const coffee = require('./loaders/coffee')
const handlebars = require('./loaders/handlebars')

environment.loaders.prepend('coffee', coffee)
environment.loaders.prepend('handlebars', handlebars)
module.exports = environment
