class CategoriesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create,:edit, :update, :destroy]
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  before_action :category_in_use?, only: [:update, :destroy]

  # GET /categories
  # GET /categories.json
  def index
    @categories =
      Category.includes(recipes: [recipe_images: [:user, image_attachment: :blob]]).
      oldest_to_newest
    @used_recipes = []
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
    @recipes =
      @category.recipes.includes(:user).
      by_published.by_name.page(params[:page]).per(30)
  end

  # GET /categories/new
  def new
    @category = Category.new
    @categories = Category.all
  end

  # GET /categories/1/edit
  def edit
    @categories = Category.all
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)
    @category.user = current_user
    @categories = Category.all

    respond_to do |format|
      if @category.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("check_boxes",
              partial: "categories/check_box",
              locals: { recipe: @recipe, category: @category }
            ),
            turbo_stream.replace("categories_list_names",
              partial: "categories/list_names",
              locals: { categories: @categories }
            ),
            turbo_stream.replace("form_category",
              partial: "categories/form",
              locals: { category: Category.new }
            )
          ]
        end
        format.html { redirect_to @category, notice: 'Category was successfully created.' }
        format.json { render :show, status: :created, location: categories_path }
        format.js
      else
        format.html { render :new }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    @category.user = current_user
    @categories = Category.all

    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: 'Category was successfully updated.' }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy
    respond_to do |format|
      format.html {
        redirect_to categories_path,
        notice: 'Category was successfully destroyed.',
        status: 303
      }
      format.json { head :no_content }
    end
  end

  def more
    @categories =
      Category.includes(recipes: [recipe_images: [:user, image_attachment: :blob]]).
      oldest_to_newest
    @used_recipes = []
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_category
    @category = Category.find(params[:id])
  end

  def category_in_use?
    if @category.in_use?
      redirect_to @category, alert: "Can't edit a category that recipes are using."
      return
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def category_params
    params.require(:category).permit(:name)
  end
end
