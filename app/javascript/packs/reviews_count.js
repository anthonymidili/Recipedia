document.addEventListener("turbo:frame-load", function() {
  var review = document.querySelector('[class*="_reviews_count"]');
  if (review) {
    var recipeId = review.dataset.recipeId;
    var count = review.dataset.count;

    var counts = document.querySelectorAll(`.recipe_${recipeId}_reviews_count`);
    counts.forEach(c => {
      c.innerHTML = count;
    });
  }
});
