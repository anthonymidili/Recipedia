# Use this instead of jQuery -> with Turbo links. Turbo links will trigger the ready page:load.
document.addEventListener 'turbolinks:load', ->
  $('.toggle').click ->
    $('.hideShow').toggle()