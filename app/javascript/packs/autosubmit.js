document.addEventListener('turbo:load', function() {

  $(".hideAndSubmit input[type='submit']").hide();

  // Submit remote false | local true forms.
  $('.hideAndSubmit.html').change(function() {
    $(this).closest('form').requestSubmit();
  });

  // Submit remote true | local false forms.
  $('.hideAndSubmit.js, .submitOnChange.js').change(function() {
    var elm = $(this).closest('form')[0]; // call native DOM element with [0]
    elm.requestSubmit();
    // $.rails.fire(elm, 'submit');
  });
});
