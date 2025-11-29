require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  def setup
    @review = reviews(:one)
    @recipe = @review.recipe
    @user = @review.user
  end

  test "should create review with valid attributes" do
    review = create_review(@recipe, @user)
    assert review.persisted?
  end

  test "review requires body" do
    review = @recipe.reviews.build(user: @user)
    assert_not review.valid?
    assert_includes review.errors[:body], "can't be blank"
  end

  test "review belongs to recipe" do
    assert_equal @recipe, @review.recipe
  end

  test "review belongs to user" do
    assert_equal @user, @review.user
  end

  test "review has rich text body" do
    assert @review.has_rich_text?(:body)
  end

  test "review has many notifications" do
    assert @review.has_many_association?(:notifications)
  end

  test "review default scope orders by created_at desc" do
    reviews = Review.all
    dates = reviews.map(&:created_at)
    assert_equal dates, dates.sort.reverse
  end

  test "review broadcasts after create" do
    review = @recipe.reviews.build(
      user: @user,
      body: ActionText::RichText.create!(body: "<p>Test review</p>")
    )

    assert_broadcast_to("reviews") do
      review.save
    end
  end

  test "review broadcasts after update" do
    @review.body = ActionText::RichText.create!(body: "<p>Updated review</p>")

    assert_broadcast_to("reviews") do
      @review.save
    end
  end

  test "review broadcasts after destroy" do
    assert_broadcast_to("reviews") do
      @review.destroy
    end
  end

  test "review enqueues recipe stats job after create" do
    review = @recipe.reviews.build(
      user: @user,
      body: ActionText::RichText.create!(body: "<p>Test</p>")
    )

    assert_enqueued_with(job: RecipeStatsJob) do
      review.save
    end
  end

  test "review enqueues notification job after create" do
    review = @recipe.reviews.build(
      user: @user,
      body: ActionText::RichText.create!(body: "<p>Test</p>")
    )

    assert_enqueued_with(job: NotifiyUsersJob) do
      review.save
    end
  end

  test "review can be updated" do
    @review.body = ActionText::RichText.create!(body: "<p>Updated</p>")
    assert @review.save
  end

  test "review can be destroyed" do
    review_id = @review.id
    @review.destroy
    assert_not Review.exists?(review_id)
  end
end
