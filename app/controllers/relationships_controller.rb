class RelationshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_relationship, only: [:show, :edit, :update, :destroy]

  # POST /relationships
  # POST /relationships.json
  def create
    @relationship = current_user.relationships.new(relationship_params)

    respond_to do |format|
      if @relationship.save
        format.html { redirect_to @relationship.followed, notice: 'Relationship was successfully created.' }
        format.json { render :show, status: :created, location: @relationship }
      else
        format.html { render :new }
        format.json { render json: @relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /relationships/1
  # DELETE /relationships/1.json
  def destroy
    other_user = User.find_by(id: @relationship.followed)
    @relationship.destroy
    respond_to do |format|
      format.html { redirect_to other_user, notice: 'Relationship was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_relationship
      @relationship = current_user.relationships.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def relationship_params
      params.require(:relationship).permit(:followed_id)
    end
end
