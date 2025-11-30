require "test_helper"

class DefaultTest < ActiveSupport::TestCase
  test "User default scope orders by username asc" do
    user1 = User.create!(username: "zebra", email: "zebra@test.com", password: "password123")
    user2 = User.create!(username: "alpha", email: "alpha@test.com", password: "password123")
    user3 = User.create!(username: "charlie", email: "charlie@test.com", password: "password123")

    users = User.where(id: [ user1.id, user2.id, user3.id ])

    assert_equal "alpha", users.first.username
    assert_equal "zebra", users.last.username
  end

  test "Part default scope orders by created_at asc" do
    recipe = recipes(:one)

    part1 = Part.create!(recipe: recipe, name: "First Part", created_at: 3.days.ago)
    part2 = Part.create!(recipe: recipe, name: "Second Part", created_at: 2.days.ago)
    part3 = Part.create!(recipe: recipe, name: "Third Part", created_at: 1.day.ago)

    parts = Part.where(id: [ part1.id, part2.id, part3.id ])

    # Should be ordered oldest first
    assert_equal part1.id, parts.first.id
    assert_equal part3.id, parts.last.id
  end

  test "Ingredient default scope orders by created_at asc" do
    recipe = recipes(:one)
    part = Part.create!(recipe: recipe, name: "Test Part")

    ingredient1 = Ingredient.create!(recipe: recipe, part: part, item: "First", created_at: 3.days.ago)
    ingredient2 = Ingredient.create!(recipe: recipe, part: part, item: "Second", created_at: 2.days.ago)
    ingredient3 = Ingredient.create!(recipe: recipe, part: part, item: "Third", created_at: 1.day.ago)

    ingredients = Ingredient.where(id: [ ingredient1.id, ingredient2.id, ingredient3.id ])

    # Should be ordered oldest first
    assert_equal ingredient1.id, ingredients.first.id
    assert_equal ingredient3.id, ingredients.last.id
  end

  test "Step default scope orders by step_order asc" do
    recipe = recipes(:one)
    part = Part.create!(recipe: recipe, name: "Test Part")

    step1 = Step.create!(
      recipe: recipe,
      part: part,
      description: "Third step",
      step_order: 3
    )
    step2 = Step.create!(
      recipe: recipe,
      part: part,
      description: "First step",
      step_order: 1
    )
    step3 = Step.create!(
      recipe: recipe,
      part: part,
      description: "Second step",
      step_order: 2
    )

    steps = Step.where(id: [ step1.id, step2.id, step3.id ])

    # Should be ordered by step_order
    assert_equal 1, steps.first.step_order
    assert_equal 3, steps.last.step_order
  end

  test "Notification default scope orders by created_at desc" do
    user = users(:one)
    notifier = users(:two)
    recipe = recipes(:one)

    notification1 = Notification.create!(
      notifiable: recipe,
      notifier: notifier,
      recipient: user,
      action: "first",
      created_at: 3.days.ago
    )
    notification2 = Notification.create!(
      notifiable: recipe,
      notifier: notifier,
      recipient: user,
      action: "second",
      created_at: 2.days.ago
    )
    notification3 = Notification.create!(
      notifiable: recipe,
      notifier: notifier,
      recipient: user,
      action: "third",
      created_at: 1.day.ago
    )

    notifications = Notification.where(id: [ notification1.id, notification2.id, notification3.id ])

    # Should be ordered newest first
    assert_equal notification3.id, notifications.first.id
    assert_equal notification1.id, notifications.last.id
  end

  test "Review default scope orders by created_at desc" do
    user = users(:one)
    recipe = recipes(:one)

    review1 = Review.create!(
      recipe: recipe,
      user: user,
      body: "First review",
      created_at: 3.days.ago
    )
    review2 = Review.create!(
      recipe: recipe,
      user: user,
      body: "Second review",
      created_at: 2.days.ago
    )
    review3 = Review.create!(
      recipe: recipe,
      user: user,
      body: "Third review",
      created_at: 1.day.ago
    )

    reviews = Review.where(id: [ review1.id, review2.id, review3.id ])

    # Should be ordered newest first
    assert_equal review3.id, reviews.first.id
    assert_equal review1.id, reviews.last.id
  end
end
