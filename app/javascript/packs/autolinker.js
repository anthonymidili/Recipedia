import Autolinker from 'autolinker'

document.addEventListener('turbo:load', function() {
  return document.querySelectorAll('.autolinks').forEach(function(index) {
    var autolinker;
    autolinker = new Autolinker({
      className: 'autolink-link'
    });
    return index.innerHTML = autolinker.link(index.innerHTML);
  });
});
