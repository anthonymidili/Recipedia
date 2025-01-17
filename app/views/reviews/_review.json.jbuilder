json.extract! review, :id, :body, :created_at, :updated_at
json.url recipe_review_url([ recipe, review ], format: :json)
