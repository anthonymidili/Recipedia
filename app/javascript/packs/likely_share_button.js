document.addEventListener("turbo:load", function() {
  var likely = require('ilyabirman-likely');
  // Finds all the widgets in the DOM and initializes them
  likely.initiate();
});
