class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recipe
  before_action :set_review, only: [:show, :edit, :update, :destroy]

  # GET /reviews
  # GET /reviews.json
  def index
    @reviews = @recipe.reviews
    @review = @recipe.reviews.new
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
  end

  # GET /reviews/new
  def new
    @review = @recipe.reviews.new
  end

  # GET /reviews/1/edit
  def edit
  end

  # POST /reviews
  # POST /reviews.json
  def create
    @review = @recipe.reviews.new(review_params)
    @review.author = current_user

    respond_to do |format|
      if @review.save
        format.html { redirect_to [@recipe, @review], notice: 'Review was successfully created.' }
        format.json { render :show, status: :created, location: [@recipe, @review] }
        format.js
      else
        format.html { render :new }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reviews/1
  # PATCH/PUT /reviews/1.json
  def update
    respond_to do |format|
      if @review.update(review_params)
        format.html { redirect_to [@recipe, @review], notice: 'Review was successfully updated.' }
        format.json { render :show, status: :ok, location: [@recipe, @review] }
      else
        format.html { render :edit }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    @review.destroy
    respond_to do |format|
      format.html { redirect_to recipe_reviews_url(@recipe), notice: 'Review was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recipe
      @recipe = Recipe.find(params[:recipe_id])
    end

    def set_review
      @review = @recipe.reviews.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def review_params
      params.require(:review).permit(:body)
    end
end
