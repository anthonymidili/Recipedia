/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

// Rails setup.
require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

// jQuery ui setup.
import Autocomplete from 'webpack-jquery-ui/autocomplete'
import Sortable from 'webpack-jquery-ui/sortable'

// Foundation setup.
import Foundation from 'foundation-sites'
$(document).on('turbolinks:load', function() {
  $(document).foundation()
});

import Autolinker from 'autolinker'

// Custom JavaScripts.
import 'packs/autocomplete'
import 'packs/direct_uploads'
import 'packs/mark_as_read'
import 'packs/sites'
import 'packs/slider'
import 'packs/touch_punch'
import 'packs/autolinker'

// Custom stylesheets.
import 'src/application'

// images and fonts.
require.context('../images', true)

// fontawesome setup.
import '@fortawesome/fontawesome-free/js/all'
import '@fortawesome/fontawesome-free/css/all'

// cocoon js setup.
import "cocoon-js"

// https://github.com/NikolayRys/Likely (share buttons)
import "ilyabirman-likely/release/likely.js"
import "ilyabirman-likely/release/likely.css"
import 'packs/likely_share_button'
