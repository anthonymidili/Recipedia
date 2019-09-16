const { environment } = require('@rails/webpacker')

const coffee =  require('./loaders/coffee')
environment.loaders.prepend('coffee', coffee)

const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    "window.jQuery": "jquery",
    "window.$": "jquery"
  })
)

module.exports = environment
