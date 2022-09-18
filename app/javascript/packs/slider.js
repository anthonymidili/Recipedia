document.addEventListener("turbo:load", function() {
  makeSlidable();
  updateStepValues();
});

$('#parts').on('cocoon:after-insert cocoon:after-remove', function() {
  makeSlidable();
  updateStepValues();
});

function makeSlidable() {
  $('.all-slides').sortable({
    handle: ".slide",
    update: function(event, ui) {
      updateStepValues();
    }
  })
};

function updateStepValues() {
  $('.all-slides').each(function(){
    $(this).find('.stepOrderField').each(function(index) {
      $(this).val(index + 1)
    })
  })
};
