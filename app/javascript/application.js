// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "@rails/activestorage"
import "./channels"
import "./controllers"
import "./jquery"

// Foundation setup.
import Foundation from 'foundation-sites'
$(document).on('turbo:load', function() {
  $(document).foundation();
});

// jQuery ui setup for Autocomplete and Sortable.
import "./packs/jquery-ui"

import './packs/autolinker'

// Custom JavaScripts.
import './packs/autocomplete'
import './packs/autofocus_cacoon'
import './packs/direct_uploads'
import './packs/mark_as_read'
import './packs/slider'
import './packs/touch_punch'
import './packs/autolinker'

// fontawesome setup.
import '@fortawesome/fontawesome-free/js/all'
// import '@fortawesome/fontawesome-free/css/all'

// cocoon js setup.
import "cocoon-js"

// https://github.com/NikolayRys/Likely (share buttons)
import "ilyabirman-likely/release/likely.js"
// import "ilyabirman-likely/release/likely.css"
import './packs/likely_share_button'
