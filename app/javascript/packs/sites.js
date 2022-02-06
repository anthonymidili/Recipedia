// Use this instead of jQuery -> with Turbo links.
// Turbo will trigger the ready page:load.
document.addEventListener('turbo:load', function() {
  return $('.toggle').click(function() {
    return $('.hideShow').toggle();
  });
});
