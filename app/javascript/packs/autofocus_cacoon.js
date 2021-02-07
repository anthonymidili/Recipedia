document.addEventListener('turbolinks:load', function() {
  $('#parts').on('cocoon:after-insert', function() {
      $('.autofocus-on-last').last().focus()
  });
});
