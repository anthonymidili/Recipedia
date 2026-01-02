class ReviewsController < ApplicationController
  before_action :authenticate_user!, except: [ :show ]
  before_action :set_recipe
  before_action :set_review, only: [ :show, :edit, :update, :destroy ]
  before_action :deny_access!,
  unless: -> { is_author?(@review.user) }, only: [ :edit, :update, :destroy ]

  def show
  end

  # GET /reviews/1/edit
  def edit
  end

  # POST /reviews
  # POST /reviews.json
  def create
    @review = @recipe.reviews.new(review_params)
    @review.user = current_user

    respond_to do |format|
      if @review.save
        format.turbo_stream do
          # Broadcast review to list from model.
          # Clear form.
          render turbo_stream: turbo_stream.replace("review_form_new_review",
            partial: "reviews/form", locals: { recipe: @recipe, review: @recipe.reviews.new })
        end
        format.html { redirect_to user_recipe_path(@recipe.user.slug, @recipe.slug), notice: "Review was successfully created." }
        format.json { render :show, status: :created, location: user_recipe_url(@recipe.user.slug, @recipe.slug) }
      else
        format.turbo_stream do
          # Display errors.
          render turbo_stream: turbo_stream.replace("review_form_new_review",
            partial: "reviews/form", locals: { recipe: @recipe, review: @review })
        end
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
        # Broadcast updated review on list from model.
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("review_#{@review.id}",
          partial: "reviews/review", locals: { review: @review })
        end
        format.html { redirect_to user_recipe_path(@recipe.user.slug, @recipe.slug, anchor: "review_#{@review.id}"), notice: "Review was successfully updated." }
        format.json { render :show, status: :ok, location: user_recipe_url(@recipe.user.slug, @recipe.slug) }
      else
        format.turbo_stream do
          # Display errors.
          render turbo_stream: turbo_stream.replace("review_form_review_#{@review.id}",
            partial: "reviews/form", locals: { recipe: @recipe, review: @review })
        end
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
      # Broadcast remove review on list from model.
      format.turbo_stream { render turbo_stream: "" }
      format.html { redirect_to user_recipe_path(@recipe.user.slug, @recipe.slug, anchor: "reviews_header"), notice: "Review was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recipe
      user = User.find_by!(slug: params[:username])
      @recipe = user.recipes.find_by!(slug: params[:recipe_slug])
    end

    def set_review
      @review = @recipe.reviews.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def review_params
      params.require(:review).permit(:body)
    end
end
