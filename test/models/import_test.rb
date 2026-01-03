require "test_helper"

class ImportTest < ActiveSupport::TestCase
  setup do
    @user = create_user
  end

  test "creates valid import with pending status" do
    import = @user.imports.build(
      url: "https://example.com/recipe",
      status: "pending"
    )

    assert import.valid?
    assert import.save
  end

  test "belongs to user" do
    import = @user.imports.create!(
      url: "https://example.com/recipe",
      status: "pending"
    )

    assert_equal @user, import.user
  end

  test "requires valid status" do
    import = @user.imports.build(
      url: "https://example.com/recipe",
      status: "invalid_status"
    )

    assert_not import.valid?
    assert_includes import.errors[:status], "is not included in the list"
  end

  test "accepts pending status" do
    import = @user.imports.build(
      url: "https://example.com/recipe",
      status: "pending"
    )

    assert import.valid?
  end

  test "accepts processing status" do
    import = @user.imports.build(
      url: "https://example.com/recipe",
      status: "processing"
    )

    assert import.valid?
  end

  test "accepts completed status" do
    import = @user.imports.build(
      url: "https://example.com/recipe",
      status: "completed"
    )

    assert import.valid?
  end

  test "accepts failed status" do
    import = @user.imports.build(
      url: "https://example.com/recipe",
      status: "failed"
    )

    assert import.valid?
  end

  test "pending? returns true for pending status" do
    import = @user.imports.create!(
      url: "https://example.com/recipe",
      status: "pending"
    )

    assert import.pending?
    assert_not import.processing?
    assert_not import.completed?
    assert_not import.failed?
  end

  test "processing? returns true for processing status" do
    import = @user.imports.create!(
      url: "https://example.com/recipe",
      status: "processing"
    )

    assert import.processing?
    assert_not import.pending?
    assert_not import.completed?
    assert_not import.failed?
  end

  test "completed? returns true for completed status" do
    import = @user.imports.create!(
      url: "https://example.com/recipe",
      status: "completed"
    )

    assert import.completed?
    assert_not import.pending?
    assert_not import.processing?
    assert_not import.failed?
  end

  test "failed? returns true for failed status" do
    import = @user.imports.create!(
      url: "https://example.com/recipe",
      status: "failed"
    )

    assert import.failed?
    assert_not import.pending?
    assert_not import.processing?
    assert_not import.completed?
  end

  test "pending scope returns only pending imports" do
    pending_import = @user.imports.create!(url: "https://example.com/1", status: "pending")
    @user.imports.create!(url: "https://example.com/2", status: "processing")
    @user.imports.create!(url: "https://example.com/3", status: "completed")

    pending_imports = Import.pending
    assert_includes pending_imports, pending_import
    assert_equal 1, pending_imports.count
  end

  test "processing scope returns only processing imports" do
    @user.imports.create!(url: "https://example.com/1", status: "pending")
    processing_import = @user.imports.create!(url: "https://example.com/2", status: "processing")
    @user.imports.create!(url: "https://example.com/3", status: "completed")

    processing_imports = Import.processing
    assert_includes processing_imports, processing_import
    assert_equal 1, processing_imports.count
  end

  test "completed scope returns only completed imports" do
    @user.imports.create!(url: "https://example.com/1", status: "pending")
    @user.imports.create!(url: "https://example.com/2", status: "processing")
    completed_import = @user.imports.create!(url: "https://example.com/3", status: "completed")

    completed_imports = Import.completed
    assert_includes completed_imports, completed_import
    assert_equal 1, completed_imports.count
  end

  test "failed scope returns only failed imports" do
    @user.imports.create!(url: "https://example.com/1", status: "pending")
    @user.imports.create!(url: "https://example.com/2", status: "completed")
    failed_import = @user.imports.create!(url: "https://example.com/3", status: "failed")

    failed_imports = Import.failed
    assert_includes failed_imports, failed_import
    assert_equal 1, failed_imports.count
  end

  test "can store error message" do
    import = @user.imports.create!(
      url: "https://example.com/recipe",
      status: "failed",
      error_message: "Recipe not found"
    )

    assert_equal "Recipe not found", import.error_message
  end

  test "can update status from pending to processing" do
    import = @user.imports.create!(
      url: "https://example.com/recipe",
      status: "pending"
    )

    import.update!(status: "processing")
    assert import.processing?
  end

  test "can update status from processing to completed" do
    import = @user.imports.create!(
      url: "https://example.com/recipe",
      status: "processing"
    )

    import.update!(status: "completed")
    assert import.completed?
  end

  test "can update status from processing to failed" do
    import = @user.imports.create!(
      url: "https://example.com/recipe",
      status: "processing"
    )

    import.update!(status: "failed", error_message: "Import error")
    assert import.failed?
    assert_equal "Import error", import.error_message
  end

  test "multiple users can have imports" do
    user2 = create_user

    import1 = @user.imports.create!(url: "https://example.com/1", status: "pending")
    import2 = user2.imports.create!(url: "https://example.com/2", status: "pending")

    assert_equal 1, @user.imports.count
    assert_equal 1, user2.imports.count
    assert_includes @user.imports, import1
    assert_includes user2.imports, import2
  end
end
