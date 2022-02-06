document.addEventListener('turbo:load', function() {
  $('#parts').on('cocoon:after-insert', function() {
      $('.autofocus-on-last').last().focus()
  });
});
