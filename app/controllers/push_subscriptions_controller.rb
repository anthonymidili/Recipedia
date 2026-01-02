class PushSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  # POST /push_subscriptions
  def create
    subscription = current_user.push_subscriptions.find_or_initialize_by(
      endpoint: subscription_params[:endpoint]
    )

    subscription.assign_attributes(
      p256dh_key: subscription_params[:keys][:p256dh],
      auth_key: subscription_params[:keys][:auth]
    )

    if subscription.save
      render json: { success: true, message: "Push notifications enabled!" }, status: :created
    else
      render json: { success: false, errors: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /push_subscriptions/:id
  def destroy
    subscription = current_user.push_subscriptions.find_by(endpoint: params[:endpoint])

    if subscription&.destroy
      render json: { success: true, message: "Push notifications disabled" }
    else
      render json: { success: false, message: "Subscription not found" }, status: :not_found
    end
  end

  # GET /push_subscriptions/vapid_public_key
  def vapid_public_key
    render json: { publicKey: Rails.application.credentials.dig(:web_push, :vapid_public_key) }
  end

  private

  def subscription_params
    params.require(:subscription).permit(:endpoint, keys: [ :p256dh, :auth ])
  end
end
