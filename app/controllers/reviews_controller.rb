class ReviewsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_recipe
  before_action :set_review, only: [:show, :edit, :update, :destroy]
  before_action :deny_access!,
  unless: -> { is_author?(@review.user) }, only: [:edit, :update, :destroy]

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
          render turbo_stream: [
            # Add review to list.
            # turbo_stream.prepend("reviews",
            #   partial: "reviews/review", locals: { review: @review }),
            # Clear form.
            turbo_stream.replace("review_form_new_review",
              partial: "reviews/form", locals: { recipe: @recipe, review: @recipe.reviews.new })
          ]
        end
        format.html { redirect_to @recipe, notice: 'Review was successfully created.' }
        format.json { render :show, status: :created, location: @recipe }
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
        # format.turbo_stream do
        #   render turbo_stream: turbo_stream.replace
        # end
        format.html { redirect_to recipe_path(@recipe, anchor: "review_#{@review.id}"), notice: 'Review was successfully updated.' }
        format.json { render :show, status: :ok, location: @recipe }
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
      format.html { redirect_to recipe_path(@recipe, anchor: "reviews_header"), notice: 'Review was successfully destroyed.' }
      format.json { head :no_content }
      format.js
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
