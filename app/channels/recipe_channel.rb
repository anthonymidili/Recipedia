class RecipeChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    recipe = Recipe.find(params[:recipe])
    stream_for recipe
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
