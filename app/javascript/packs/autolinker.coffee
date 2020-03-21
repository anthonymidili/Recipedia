document.addEventListener 'turbolinks:load', ->
  document.querySelectorAll('.autolinks').forEach (index) ->
    autolinker = new Autolinker(className: 'autolink-link')
    index.innerHTML = autolinker.link(index.innerHTML)
