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
    assert_respond_to @review, :body
    assert @review.body.to_s.present?
  end

  test "review has many notifications" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @review.notifications
  end

  test "review default scope orders by created_at desc" do
    reviews = Review.all
    dates = reviews.map(&:created_at)
    assert_equal dates, dates.sort.reverse
  end

  test "review broadcasts after create" do
    review = @recipe.reviews.build(
      user: @user,
      body: "Test review"
    )

    perform_enqueued_jobs do
      review.save
    end
    assert review.persisted?
  end

  test "review broadcasts after update" do
    @review.body = "Updated review"

    perform_enqueued_jobs do
      assert @review.save
    end
  end

  test "review broadcasts after destroy" do
    perform_enqueued_jobs do
      @review.destroy
    end
    assert @review.destroyed?
  end

  test "review enqueues recipe stats job after create" do
    review = @recipe.reviews.build(
      user: @user,
      body: "Test"
    )

    assert_enqueued_with(job: RecipeStatsJob) do
      review.save
    end
  end

  test "review enqueues notification job after create" do
    review = @recipe.reviews.build(
      user: @user,
      body: "Test"
    )

    assert_enqueued_with(job: NotifiyUsersJob) do
      review.save
    end
  end

  test "review can be updated" do
    @review.body = "Updated"
    assert @review.save
  end

  test "review can be destroyed" do
    review_id = @review.id
    @review.destroy
    assert_not Review.exists?(review_id)
  end
end
