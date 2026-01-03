require "test_helper"

class RecipeImporterTest < ActiveSupport::TestCase
  test "creates RecipeImporter with URL" do
    importer = RecipeImporter.new("https://example.com/recipe")
    assert_not_nil importer
  end

  test "ImportError is a StandardError" do
    assert RecipeImporter::ImportError < StandardError
  end
end
