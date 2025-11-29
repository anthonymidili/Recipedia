ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Use FactoryBot for test data by default (fixtures disabled)
    # fixtures :users, :categories, :recipes, :categorizations,
    #          :relationships, :notifications, :recipe_images,
    #          :reviews, :notification_settings, :infos

    # Include FactoryBot methods
    include FactoryBot::Syntax::Methods

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
          if respond_to?(related_factory_plural)
            attrs[assoc_name.to_sym] = load_factory_fixture(related_factory_plural, key)
          end
        end
      end

      @factory_cache[factory_name][key] = FactoryBot.create(factory_sym, **attrs)
    end

    %w[users categories recipes recipe_images relationships reviews notifications notification_settings parts ingredients steps].each do |name|
      define_method(name) do |key = :one|
        load_factory_fixture(name, key)
      end
    end

    # Helper methods
    def sign_in(user)
      post user_session_path, params: {
        user: { email: user.email, password: "password" }
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
        body: ActionText::RichText.create!(body: "<p>Great recipe!</p>"),
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
    def sign_in(user, password = "password")
      post user_session_path, params: {
        user: { email: user.email, password: password }
      }
    end

    def sign_out
      delete destroy_user_session_path
    end
  end
end
