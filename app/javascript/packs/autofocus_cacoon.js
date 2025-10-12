document.addEventListener('turbo:load', function() {
  $('#parts').on('cocoon:after-insert', function(e, insertedItem) {
    insertedItem.find('.autofocus-on-new').focus();
  });
});
