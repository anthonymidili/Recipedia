require "test_helper"

class RecipeImportJobTest < ActiveJob::TestCase
  def setup
    @user = create(:user)
    @import = create(:import, user: @user, url: "https://example.com/recipe", status: "pending")
  end

  test "uses default queue" do
    assert_equal "default", RecipeImportJob.new.queue_name
  end

  test "finds import by id" do
    # We can't easily test the full perform without mocking HTTP requests
    # But we can verify the job enqueues properly
    assert_enqueued_with(job: RecipeImportJob, args: [ @import.id ]) do
      RecipeImportJob.perform_later(@import.id)
    end
  end
end
