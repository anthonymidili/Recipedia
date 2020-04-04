module MetaTagsHelper
  def set_root_meta_tag_options
    set_meta_tags description: "A Place to keep and share your recipes.",
      twitter: {
        card:  "summary",
        title: "Recipedia | Let's cook together",
        description: "A Place to keep and share your recipes.",
        url: root_url,
        secure_url: root_url,
        image: {
          _: (request.host_with_port + ActionController::Base.helpers.asset_pack_path('media/images/spice.jpg')),
          sucure_url: (request.host_with_port + ActionController::Base.helpers.asset_pack_path('media/images/spice.jpg')),
          width: 600,
          height: 400,
          type: "image/jpeg"
        }
      },
      og: {
        title: "Recipedia | Let's cook together",
        description: "A Place to keep and share your recipes.",
        type: 'website',
        url: root_url,
        secure_url: root_url,
        image: {
          _: (request.host_with_port + ActionController::Base.helpers.asset_pack_path('media/images/spice.jpg')),
          sucure_url: (request.host_with_port + ActionController::Base.helpers.asset_pack_path('media/images/spice.jpg')),
          width: 600,
          height: 400,
          type: "image/jpeg"
        }
      }
  end

  def recipe_meta_tag_options(recipe)
    set_meta_tags description: recipe.description,
      keywords: recipe.categories.list_names,
      twitter: {
        card:  "summary",
        title: recipe.name,
        description: recipe.description,
        url: recipe_url(recipe),
        secure_url: recipe_url(recipe),
        image: {
          _: image_url(recipe),
          width: 400,
          height: 400,
          type: (recipe.image.blob.content_type if recipe.image.attached?)
        }
      },
      og: {
        title: recipe.name,
        description: recipe.description,
        type: 'website',
        url: recipe_url(recipe),
        secure_url: recipe_url(recipe),
        image: {
          _: image_url(recipe),
          width: 400,
          height: 400,
          type: (recipe.image.blob.content_type if recipe.image.attached?)
        }
      }
  end

  private

  def image_url(recipe)
    image_url = recipe.image.service_url if recipe.image.attached?
    if image_url
      image_url.slice! "s3.amazonaws.com/"
      image_url
    end
  end
end
