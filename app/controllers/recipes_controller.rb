class RecipesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :log_in]
  before_action :set_recipe, only: [:show, :edit, :update, :destroy, :log_in, :likes, :upload_image, :update_image]
  before_action :deny_access!,
  unless: -> { is_author?(@recipe.user) }, only: [:edit, :update, :destroy]
  before_action :set_category, only: [:new, :create, :edit, :update]
  before_action :remove_image, only: [:update]
  # rescue_from Aws::S3::Errors::NoSuchKey, with: :cleanup_image
  before_action :set_root_meta_tag_options, only: [:index]
  before_action :set_recipe_meta_tag_options, only: [:show]
  rescue_from ActionController::ParameterMissing, with: :no_image_uploaded

  # GET /recipes
  # GET /recipes.json
  def index
    @recipes =
      if params[:search]
        Recipe.by_published.newest_to_oldest.filtered_by(params[:search]).page(params[:page])
      else
        Recipe.by_published.newest_to_oldest.page(params[:page])
      end
  end

  # GET /recipes/1
  # GET /recipes/1.json
  def show
    @image = @recipe.images.find_by(id: params[:image]) || @recipe.images.first if @recipe.images.attached?
    @review = @recipe.reviews.new
  end

  # GET /recipes/new
  def new
    @recipe = current_user.recipes.build
    @recipe.parts.build
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
          format.html { redirect_to @recipe, notice: 'Recipe was successfully created.' }
          format.json { render :show, status: :created, location: @recipe }
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
        format.html { redirect_to @recipe, notice: 'Recipe was successfully updated.' }
        format.json { render :show, status: :ok, location: @recipe }
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
      format.html { redirect_to recipes_url, notice: 'Recipe was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    @recipes = Recipe.by_published.filtered_by(params[:term])
    render json: @recipes.pluck(:name)
  end

  def log_in
    redirect_to @recipe
  end

  def likes
  end

  def upload_image
  end

  def update_image
    @recipe.images.attach(params[:recipe][:images]) if params[:recipe][:images].present?

    respond_to do |format|
      if @recipe.update(recipe_params)
        format.html { redirect_to upload_image_recipe_path(@recipe), notice: 'Images were successfully updated.' }
        format.json { render :update_image, status: :ok, location: upload_image_recipe_path(@recipe) }
      else
        format.html { render :update_image }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def set_category
    @category = Category.new
  end

  def remove_image
    @images = @recipe.images.where(id: recipe_params[:remove_images])
    @images.purge_later if @images
  end

  def cleanup_image
    recipe_params.delete(:image)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def recipe_params
    params.require(:recipe).permit(:name, :description, :source, :published, remove_images: [], images: [], category_ids: [],
                                   parts_attributes: [:id, :name, :_destroy,
                                                      ingredients_attributes: [:id, :item, :quantity, :_destroy],
                                                      steps_attributes: [:id, :description, :step_order, :_destroy]])
  end

  def no_image_uploaded
    redirect_to upload_image_recipe_path(@recipe), notice: 'No image uploaded.'
  end

  def set_recipe_meta_tag_options
    recipe_meta_tag_options(@recipe)
  end
end
