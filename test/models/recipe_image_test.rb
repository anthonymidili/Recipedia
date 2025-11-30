require "test_helper"

class RecipeImageTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @recipe = recipes(:one)
  end

  test "should create valid recipe image" do
    recipe_image = RecipeImage.new(
      recipe: @recipe,
      user: @user
    )

    assert recipe_image.valid?
    assert recipe_image.save
  end

  test "should belong to recipe" do
    recipe_image = RecipeImage.create!(
      recipe: @recipe,
      user: @user
    )

    assert_equal @recipe, recipe_image.recipe
  end

  test "should belong to user" do
    recipe_image = RecipeImage.create!(
      recipe: @recipe,
      user: @user
    )

    assert_equal @user, recipe_image.user
  end

  test "should require recipe" do
    recipe_image = RecipeImage.new(user: @user)

    assert_not recipe_image.valid?
  end

  test "should require user" do
    recipe_image = RecipeImage.new(recipe: @recipe)

    assert_not recipe_image.valid?
  end

  test "should have one attached image" do
    recipe_image = RecipeImage.create!(
      recipe: @recipe,
      user: @user
    )

    assert_respond_to recipe_image, :image
  end

  test "should have notifications association" do
    recipe_image = RecipeImage.create!(
      recipe: @recipe,
      user: @user
    )

    assert_respond_to recipe_image, :notifications
  end

  test "should create notification after commit" do
    # Clear existing jobs
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear

    assert_enqueued_with(job: NotifiyUsersJob) do
      RecipeImage.create!(
        recipe: @recipe,
        user: @user
      )
    end
  end

  test "by_original_first scope orders first image first, rest newest to oldest" do
    # Create recipe images with different timestamps
    image1 = RecipeImage.create!(
      recipe: @recipe,
      user: @user,
      created_at: 4.days.ago
    )

    image2 = RecipeImage.create!(
      recipe: @recipe,
      user: @user,
      created_at: 3.days.ago
    )

    image3 = RecipeImage.create!(
      recipe: @recipe,
      user: @user,
      created_at: 2.days.ago
    )

    image4 = RecipeImage.create!(
      recipe: @recipe,
      user: @user,
      created_at: 1.day.ago
    )

    images = RecipeImage.where(id: [ image1.id, image2.id, image3.id, image4.id ])
    ordered_images = images.by_original_first

    # [1, 2, 3, 4] becomes [1, 4, 3, 2]
    assert_equal image1.id, ordered_images[0].id, "First image should stay first"
    assert_equal image4.id, ordered_images[1].id, "Newest should be second"
    assert_equal image3.id, ordered_images[2].id, "Second newest should be third"
    assert_equal image2.id, ordered_images[3].id, "Third newest should be fourth"
  end

  test "recipe can have many recipe_images" do
    assert_respond_to @recipe, :recipe_images

    image1 = RecipeImage.create!(recipe: @recipe, user: @user)
    image2 = RecipeImage.create!(recipe: @recipe, user: @user)

    assert_includes @recipe.recipe_images.reload, image1
    assert_includes @recipe.recipe_images.reload, image2
  end

  test "should destroy associated notifications when destroyed" do
    recipe_image = RecipeImage.create!(recipe: @recipe, user: @user)

    Notification.create!(
      notifiable: recipe_image,
      notifier: @user,
      recipient: users(:two),
      action: "uploaded image"
    )

    assert_difference "Notification.count", -1 do
      recipe_image.destroy
    end
  end
end
