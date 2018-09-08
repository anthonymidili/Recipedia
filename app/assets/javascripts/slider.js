document.addEventListener("turbolinks:load", function() {
  function updateStepValues() {
    $('.all-slides').each(function(){
      $(this).find('.stepOrderField').each(function(index) {
        $(this).val(index + 1)
      });
    });
  }

  function makeSlidable() {
    $('.all-slides').sortable({
      handle: ".slide",
      update: function(event, ui) {
        updateStepValues();
      }
    });
  }

  // initiate makeSlidable on page load
  makeSlidable();

  $('#parts').on('cocoon:after-insert cocoon:after-remove', function() {
    updateStepValues();
    makeSlidable();
  });
});
