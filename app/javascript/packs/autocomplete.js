document.addEventListener("turbo:load", function() {
  var searchBox = $('#search');
  searchBox.autocomplete({
    source: searchBox.data('autocomplete-source'),
    minLength: 1,
    select: function(event, ui) {
      event.preventDefault();
      var url = ui.item.url;
      if (url && url.startsWith('/')) {
        window.location.href = url;
      }
    }
  }).autocomplete("instance")._renderItem = function(ul, item) {
    var card = $('<div class="autocomplete-recipe-card">');

    if (item.image_url) {
      card.append($('<img class="autocomplete-recipe-img">').attr('src', item.image_url).attr('alt', ''));
    } else {
      card.append($('<div class="autocomplete-recipe-img autocomplete-recipe-img--default">').append('<i class="fas fa-utensils"></i>'));
    }

    var info = $('<div class="autocomplete-recipe-info">');
    info.append($('<div class="autocomplete-recipe-name">').text(item.label));
    info.append($('<div class="autocomplete-recipe-user">').text('by ' + item.username));
    card.append(info);

    return $('<li>').append(card).appendTo(ul);
  };
});
