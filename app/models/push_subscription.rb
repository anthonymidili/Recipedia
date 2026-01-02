class PushSubscription < ApplicationRecord
  belongs_to :user

  validates :endpoint, presence: true, uniqueness: true
  validates :p256dh_key, presence: true
  validates :auth_key, presence: true

  # Remove invalid subscriptions
  def self.cleanup_invalid!
    where(endpoint: nil).or(where(p256dh_key: nil)).or(where(auth_key: nil)).destroy_all
  end
end
