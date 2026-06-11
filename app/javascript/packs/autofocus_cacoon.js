document.addEventListener('turbo:load', function() {
  // Autofocus the first new field when a part is added via cocoon.
  // Step autofocus is handled by the Stimulus StepsController.
  $('.parts').on('cocoon:after-insert', function(e, insertedItem) {
    insertedItem.find('.autofocus-on-new').first().focus();
  });
});
