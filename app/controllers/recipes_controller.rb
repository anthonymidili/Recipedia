class RecipesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create,:edit, :update, :destroy]
  before_action :set_recipe, only: [:show]
  before_action :set_user_recipe, only: [:edit, :update, :destroy]

  # GET /recipes
  # GET /recipes.json
  def index
    @recipes =
      if params[:search]
        Recipe.newest_to_oldest.filtered_by(params[:search]).page(params[:page])
      else
        Recipe.newest_to_oldest.page(params[:page])
      end
  end

  # GET /recipes/1
  # GET /recipes/1.json
  def show
  end

  # GET /recipes/new
  def new
    @recipe = current_user.recipes.new
  end

  # GET /recipes/1/edit
  def edit
  end

  # POST /recipes
  # POST /recipes.json
  def create
    @recipe = current_user.recipes.new(recipe_params)
    @recipe.image.attach(recipe_params[:image])

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

  # PATCH/PUT /recipes/1
  # PATCH/PUT /recipes/1.json
  def update
    @recipe.image.attach(params[:recipe][:image])

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
    # @recipe.image.purge if @recipe.image.attached?
    @recipe.destroy
    respond_to do |format|
      format.html { redirect_to recipes_url, notice: 'Recipe was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    @recipes = Recipe.filtered_by(params[:term])
    render json: @recipes.pluck(:name)
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def set_user_recipe
    @recipe = current_user.recipes.find_by(id: params[:id])
    redirect_to root_path unless @recipe
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def recipe_params
    params.require(:recipe).permit(:name, :description, :source, :image, category_ids: [],
                                   parts_attributes: [:id, :name, :_destroy,
                                                      ingredients_attributes: [:id, :item, :quantity, :_destroy],
                                                      steps_attributes: [:id, :description, :_destroy]])
  end
end
