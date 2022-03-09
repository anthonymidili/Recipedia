import consumer from "./consumer"

document.addEventListener('turbo:load', function() {
  // Find all recipes on page and subscribe to the channel.
  var recipes = document.querySelectorAll("[id^='recipe_']");
  recipes.forEach(function(recipe) {
    var recipe_id = recipe.getAttribute('data-recipe-id');
    consumer.subscriptions.create({ channel: "RecipeChannel", recipe: recipe_id }, {
      connected() {
        // Called when the subscription is ready for use on the server.
      },

      disconnected() {
        // Called when the subscription has been terminated by the server.
      },

      received(data) {
        // Called when there's incoming data on the websocket for this channel.
        // Set recipe reviews count on all reviews_count_recipe_## classes.
        var reviews_count = document.querySelectorAll(".reviews_count_recipe_" + recipe_id);
        reviews_count.forEach(function(review_count) {
          review_count.innerHTML = data.reviews_count;
        });

        // Set recipe likes count on recipe_likes_count_## id by replacing the partial.
        var likes_count = document.querySelector("#recipe_likes_count_" + recipe_id);
        likes_count.innerHTML = data.likes_partial;
      }
    });
  });
});
