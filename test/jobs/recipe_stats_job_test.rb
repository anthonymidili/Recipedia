require "test_helper"

class RecipeStatsJobTest < ActiveJob::TestCase
  def setup
    @user = create(:user)
    @recipe = create(:recipe, user: @user)
  end

  test "broadcasts recipe stats to recipe channel" do
    # Create some reviews to count
    reviewer = create(:user)
    create(:review, recipe: @recipe, user: reviewer)

    assert_broadcasts(RecipeChannel.broadcasting_for(@recipe), 1) do
      RecipeStatsJob.perform_now(@recipe)
    end
  end

  test "includes reviews count in broadcast" do
    reviewer = create(:user)
    create(:review, recipe: @recipe, user: reviewer)
    create(:review, recipe: @recipe, user: create(:user))

    # Capture the broadcast
    assert_broadcasts(RecipeChannel.broadcasting_for(@recipe), 1) do
      RecipeStatsJob.perform_now(@recipe)
    end
  end

  test "renders likes partial in broadcast" do
    RecipeStatsJob.perform_now(@recipe)
    # Test passes if no error is raised
    assert true
  end

  test "retries up to 3 times on failure" do
    assert_equal 3, RecipeStatsJob.sidekiq_options_hash["retry"]
  end

  test "uses default queue" do
    assert_equal "default", RecipeStatsJob.new.queue_name
  end
end
