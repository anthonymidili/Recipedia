class RecipesController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy, :log_in ]
  before_action :set_recipe, only: [ :show, :edit, :update, :destroy, :log_in, :likes ]
  before_action :deny_access!,
  unless: -> { is_author?(@recipe.user) || is_site_admin? }, only: [ :edit, :update, :destroy ]
  before_action :set_category, only: [ :new, :create, :edit, :update ]
  before_action :set_root_meta_tag_options, only: [ :index ]
  before_action :set_recipe_meta_tag_options, only: [ :show ]

  skip_before_action :verify_authenticity_token, only: [ :import ]

  # GET /recipes
  # GET /recipes.json
  def index
    @recipes =
      if params[:search]
        Recipe.includes(:user).by_published.newest_to_oldest.
        filtered_by(params[:search]).page(params[:page]).per(30)
      else
        Recipe.includes(:user).by_published.newest_to_oldest.
        page(params[:page]).per(30)
      end
  end

  # GET /recipes/1
  # GET /recipes/1.json
  def show
    if @recipe.recipe_images
      @recipe_image = @recipe.recipe_images.find_by(id: params[:image]) || @recipe.recipe_images.first
    end
    @review = @recipe.reviews.new

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("main_recipe_image",
          partial: "recipe_images/recipe_image", locals: { recipe_image: @recipe_image })
      end
      format.html
    end
  end

  # GET /recipes/new
  def new
    @recipe = current_user.recipes.build
    @recipe.parts.build

    # Check for imported data
    if session[:import_id]
      import = current_user.imports.find_by(id: session[:import_id])
      if import
        @recipe.name = import.title
        @recipe.description = import.description
        @recipe.source = import.source

        # Build ingredients (format: "quantity|item" or "|item" for no quantity)
        import.ingredients.split("\n").each do |ing|
          parts = ing.split("|", 2)
          quantity = parts[0].presence
          item = parts[1] || ing # Fallback to full string if no pipe found
          @recipe.parts.first.ingredients.build(quantity: quantity, item: item)
        end

        # Build steps
        import.instructions.split("\n").each do |inst|
          @recipe.parts.first.steps.build(description: inst)
        end

        # Clean up the import
        import.destroy
        session.delete(:import_id)
      end
    else
      # Default empty fields for manual creation
      @recipe.parts.first.ingredients.build
      @recipe.parts.first.steps.build
    end
  end

  # GET /recipes/1/edit
  def edit
    @recipe.parts.build if @recipe.parts.blank?
  end

  # POST /recipes
  # POST /recipes.json
  def create
    ActiveRecord::Base.transaction do
      @recipe = current_user.recipes.build(recipe_params)

      respond_to do |format|
        if @recipe.save
        format.html { redirect_to user_recipe_path(@recipe.user.slug, @recipe.slug), notice: "Recipe was successfully created." }
        format.json { render :show, status: :created, location: user_recipe_url(@recipe.user.slug, @recipe.slug) }
        else
          format.html { render :new }
          format.json { render json: @recipe.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /recipes/1
  # PATCH/PUT /recipes/1.json
  def update
    respond_to do |format|
      if @recipe.update(recipe_params)
        @recipes_unpublished_count = current_user.recipes.by_unpublished.count
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("publish_form_recipe_#{@recipe.id}"),
            turbo_stream.replace("unpublished_count", partial: "recipes/unpublished_count")
          ]
        end
        format.html { redirect_to user_recipe_path(@recipe.user.slug, @recipe.slug), notice: "Recipe was successfully updated." }
        format.json { render :show, status: :ok, location: user_recipe_url(@recipe.user.slug, @recipe.slug) }
      else
        format.html { render :edit }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recipes/1
  # DELETE /recipes/1.json
  def destroy
    @recipe.destroy
    respond_to do |format|
      format.html {
        redirect_to recipes_url,
        notice: "Recipe was successfully destroyed.",
        status: 303
      }
      format.json { head :no_content }
    end
  end

  def search
    @recipes = Recipe.by_published.filtered_by(params[:term])
    render json: @recipes.pluck(:name)
  end

  def choice
  end

  def log_in
    redirect_to user_recipe_path(@recipe.user.slug, @recipe.slug)
  end

  def likes
  end

  def import
    url = params[:url]

    begin
      importer = RecipeImporter.new(url)
      data = importer.import

      # Validate that we found recipe content
      if data[:ingredients].empty? && data[:instructions].empty?
        Rails.logger.warn "No recipe content found for URL: #{url}"
        respond_to do |format|
          format.json { render json: { error: "No recipe ingredients or instructions found on this page. Please make sure you're importing from a recipe page, not an article or review page." }, status: :unprocessable_entity }
          format.html do
            flash[:alert] = "No recipe ingredients or instructions found on this page. Please make sure you're importing from a recipe page, not an article or review page."
            redirect_to choice_recipes_path
          end
        end
        return
      end

      respond_to do |format|
        format.json { render json: data }
        format.html do
          # Format ingredients with quantity and item separated by pipe
          formatted_ingredients = data[:ingredients].map do |ing|
            if ing[:quantity].present?
              "#{ing[:quantity]}|#{ing[:item]}"
            else
              "|#{ing[:item]}"
            end
          end

          import = current_user.imports.create!(
            title: data[:name],
            description: data[:description],
            source: data[:source],
            ingredients: formatted_ingredients.join("\n"),
            instructions: data[:instructions].join("\n")
          )
          session[:import_id] = import.id
          flash[:warning] = "Recipe imported successfully! Please double-check all fields against the original recipe before saving."
          redirect_to new_recipe_path
        end
      end
    rescue RecipeImporter::ImportError => e
      Rails.logger.warn "Import blocked for #{url}: #{e.message}"
      respond_to do |format|
        format.json { render json: { error: e.message }, status: :unprocessable_entity }
        format.html do
          flash[:alert] = e.message
          redirect_to choice_recipes_path
        end
      end
    rescue => e
      Rails.logger.error "Import error for #{url}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      respond_to do |format|
        format.json { render json: { error: e.message }, status: :unprocessable_entity }
        format.html do
          flash[:alert] = "Failed to import recipe: #{e.message}"
          redirect_to choice_recipes_path
        end
      end
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_recipe
    # Scoped route: /recipes/:username/:slug
    user = User.find_by!(slug: params[:username])
    @recipe = user.recipes.includes(
      :user,
      parts: [ :ingredients, :steps ],
      reviews: [ user: [ avatar_attachment: :blob ] ],
      recipe_images: [ :user, image_attachment: :blob ]
    ).find_by!(slug: params[:slug])
  end

  def set_category
    @category = Category.new
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def recipe_params
    params.require(:recipe).permit(:name, :description, :source, :published, category_ids: [],
      parts_attributes: [ :id, :name, :_destroy,
        ingredients_attributes: [ :id, :item, :quantity, :_destroy ],
        steps_attributes: [ :id, :description, :step_order, :_destroy ] ])
  end

  def set_recipe_meta_tag_options
    recipe_meta_tag_options(@recipe)
  end
end
