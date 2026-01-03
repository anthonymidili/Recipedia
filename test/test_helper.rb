ENV["RAILS_ENV"] ||= "test"

# Ensure test directory is in load path for requiring test_helper
test_dir = File.expand_path(__dir__)
$LOAD_PATH.unshift(test_dir) unless $LOAD_PATH.include?(test_dir)

require_relative "../config/environment"
require "rails/test_help"
require "active_job/test_helper"
# ActionCable test helper is provided via ActiveSupport in Rails; use included helpers

# Set ActiveStorage URL options for tests
ActiveStorage::Current.url_options = { host: "http://www.example.com" }

module ActiveSupport
  class TestCase
    # Run tests serially to avoid issues with parallel test execution
    # Note: Rails 8.1.x has a known issue where `bin/rails test` doesn't load test files properly.
    # Fixed by custom bin/test script and lib/tasks/test.rake
    # To run tests:
    #   1. bin/test (runs all tests - 265 tests)
    #   2. bundle exec rake test (runs all tests)
    #   3. bundle exec rake test:models (runs only model tests)
    #   4. ruby -Itest test/models/user_test.rb (run individual files)
    parallelize(workers: 1)

    # Set ActiveStorage URL options for each test
    setup do
      ActiveStorage::Current.url_options = { host: "http://www.example.com" }
    end

    # Use FactoryBot for test data by default (fixtures disabled)
    # fixtures :users, :categories, :recipes, :categorizations,
    #          :relationships, :notifications, :recipe_images,
    #          :reviews, :notification_settings, :infos

    # Include FactoryBot methods
    include FactoryBot::Syntax::Methods
    include ActiveJob::TestHelper
    include ActionCable::TestHelper

    # Provide fixture-style helper methods (e.g. users(:one)) that fall back to factories.
    def load_factory_fixture(factory_name, key = :one)
      @factory_cache ||= {}
      @factory_cache[factory_name] ||= {}
      return @factory_cache[factory_name][key] if @factory_cache[factory_name][key]

      factory_sym = factory_name.to_s.singularize.to_sym
      model_class = factory_sym.to_s.classify.safe_constantize

      # Build associated belongs_to fixtures first so associations reuse the same key
      attrs = {}
      if model_class
        model_class.reflect_on_all_associations(:belongs_to).each do |assoc|
          assoc_name = assoc.name.to_s
          related_factory_plural = assoc_name.pluralize

          # Special case: Relationship associations should match fixture data
          if model_class == Relationship
            if assoc_name == "followed"
              # relationships(:one) -> followed: users(:one)
              # relationships(:two) -> followed: users(:one)
              # relationships(:three) -> followed: users(:two)
              followed_key = case key.to_sym
              when :one then :one
              when :two then :one
              when :three then :two
              else :one
              end
              attrs[:followed] = load_factory_fixture("users", followed_key)
            elsif assoc_name == "user"
              # relationships(:one) -> user: users(:two)
              # relationships(:two) -> user: users(:three)
              # relationships(:three) -> user: users(:one)
              user_key = case key.to_sym
              when :one then :two
              when :two then :three
              when :three then :one
              else key
              end
              attrs[:user] = load_factory_fixture("users", user_key)
            end
          # Special case: Recipe belongs to user - match fixture data
          elsif model_class == Recipe && assoc_name == "user"
            user_key = case key.to_sym
            when :one, :two then :one    # recipes(:one) and recipes(:two) belong to users(:one)
            when :three, :four then :two # recipes(:three) and recipes(:four) belong to users(:two)
            else key
            end
            attrs[:user] = load_factory_fixture("users", user_key)
          elsif respond_to?(related_factory_plural)
            attrs[assoc_name.to_sym] = load_factory_fixture(related_factory_plural, key)
          end
        end
      end

      obj = FactoryBot.create(factory_sym, **attrs)

      # Special wiring for many-to-many associations and fixture-specific attributes
      if model_class == Recipe
        # Set attributes based on fixture key to match fixture expectations
        case key.to_sym
        when :one
          obj.update_columns(name: "Pasta Recipe", published: true)
        when :two
          obj.update_columns(name: "Soup Recipe", published: true)
        when :three
          obj.update_columns(name: "Draft Recipe", published: false)
        when :four
          obj.update_columns(name: "Salad Recipe", published: true)
        end

        begin
          cat = @factory_cache.dig("categories", key) || FactoryBot.create(:category, user: obj.user)
          obj.categories << cat unless obj.categories.exists?(cat.id)
        rescue StandardError
        end
      elsif model_class == Category
        if key.to_sym == :one
          # Ensure specific recipes(:one) and recipes(:two) exist and are attached
          @factory_cache["recipes"] ||= {}
          @factory_cache["recipes"][:one] ||= FactoryBot.create(:recipe, user: obj.user)
          @factory_cache["recipes"][:two] ||= FactoryBot.create(:recipe, user: obj.user)

          r1 = @factory_cache["recipes"][:one]
          r2 = @factory_cache["recipes"][:two]
          r1.categories = [ obj ]
          r2.categories = [ obj ]
        end
      end

      @factory_cache[factory_name][key] = obj
    end

    %w[users categories recipes recipe_images relationships reviews notifications notification_settings parts ingredients steps].each do |name|
      define_method(name) do |key = :one|
        load_factory_fixture(name, key)
      end
    end

    # Helper methods
    def sign_in(user)
      post user_session_path, params: {
        user: { email: user.email, password: "password123" }
      }
    end

    def sign_out
      delete destroy_user_session_path
    end

    def create_user(attributes = {})
      User.create!(
        username: "testuser_#{SecureRandom.hex(4)}",
        email: "test_#{SecureRandom.hex(4)}@example.com",
        password: "password123",
        password_confirmation: "password123",
        **attributes
      )
    end

    def create_category(attributes = {})
      # Allow passing a User directly for convenience
      if attributes.is_a?(User)
        attributes = { user: attributes }
      end
      Category.create!(
        name: "Category #{SecureRandom.hex(4)}",
        **attributes
      )
    end

    def create_recipe(user = nil, attributes = {})
      user ||= create_user
      category = create_category(user: user)
      Recipe.create!(
        name: "Test Recipe #{SecureRandom.hex(4)}",
        user: user,
        category_ids: [ category.id ],
        published: true,
        **attributes
      )
    end

    def create_review(recipe = nil, user = nil, attributes = {})
      recipe ||= create_recipe
      user ||= create_user
      Review.create!(
        recipe: recipe,
        user: user,
        body: "Great recipe!",
        **attributes
      )
    end

    def create_ingredient(recipe = nil, attributes = {})
      recipe ||= create_recipe
      Ingredient.create!(
        recipe: recipe,
        name: "Test Ingredient #{SecureRandom.hex(4)}",
        quantity: "1",
        unit: "cup",
        **attributes
      )
    end

    def create_step(recipe = nil, attributes = {})
      recipe ||= create_recipe
      Step.create!(
        recipe: recipe,
        step_number: 1,
        description: "Test step #{SecureRandom.hex(4)}",
        **attributes
      )
    end
  end
end

module ActionDispatch
  class IntegrationTest
    setup do
      ActiveStorage::Current.url_options = { host: "http://www.example.com" }
    end

    def sign_in(user, password = "password123")
      post user_session_path, params: {
        user: { email: user.email, password: password }
      }
    end

    def sign_out
      delete destroy_user_session_path
    end

    # Custom URL helper methods to match the scoped routing structure
    # Recipes are nested under /recipes/:username
    def recipe_url(recipe, options = {})
      user_recipe_url(recipe.user.slug, recipe.slug, options)
    end

    def recipe_path(recipe, options = {})
      user_recipe_path(recipe.user.slug, recipe.slug, options)
    end

    def edit_recipe_url(recipe)
      edit_user_recipe_url(recipe.user.slug, recipe.slug)
    end

    def edit_recipe_path(recipe)
      edit_user_recipe_path(recipe.user.slug, recipe.slug)
    end

    # Recipe images nested under recipes
    def recipe_recipe_images_url(recipe)
      user_recipe_recipe_images_url(recipe.user.slug, recipe.slug)
    end

    def recipe_recipe_images_path(recipe)
      user_recipe_recipe_images_path(recipe.user.slug, recipe.slug)
    end

    def new_recipe_recipe_image_url(recipe)
      new_user_recipe_recipe_image_url(recipe.user.slug, recipe.slug)
    end

    def new_recipe_recipe_image_path(recipe)
      new_user_recipe_recipe_image_path(recipe.user.slug, recipe.slug)
    end

    def recipe_recipe_image_url(recipe, recipe_image)
      user_recipe_recipe_image_url(recipe.user.slug, recipe.slug, recipe_image)
    end

    def recipe_recipe_image_path(recipe, recipe_image)
      user_recipe_recipe_image_path(recipe.user.slug, recipe.slug, recipe_image)
    end

    # Reviews nested under recipes
    def recipe_reviews_url(recipe)
      user_recipe_reviews_url(recipe.user.slug, recipe.slug)
    end

    def recipe_reviews_path(recipe)
      user_recipe_reviews_path(recipe.user.slug, recipe.slug)
    end

    def recipe_review_url(recipe, review)
      user_recipe_review_url(recipe.user.slug, recipe.slug, review)
    end

    def recipe_review_path(recipe, review)
      user_recipe_review_path(recipe.user.slug, recipe.slug, review)
    end

    def edit_recipe_review_url(recipe, review)
      edit_user_recipe_review_url(recipe.user.slug, recipe.slug, review)
    end

    def edit_recipe_review_path(recipe, review)
      edit_user_recipe_review_path(recipe.user.slug, recipe.slug, review)
    end
  end
end
