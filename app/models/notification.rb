class Notification < ApplicationRecord
  belongs_to :notifiable, polymorphic: true
  belongs_to :notifier, class_name: "User"
  belongs_to :recipient, class_name: "User"

  default_scope { order(created_at: :desc) }
  scope :by_unread, -> { where(is_read: false) }
  scope :by_read, -> { where(is_read: true) }
  scope :unread_count, -> { by_unread.count }
  scope :mark_as_read, -> { update_all(is_read: true) if any? }
  scope :by_older_than_month, -> { where("created_at < :time", time: (DateTime.current - 1.month)) }
end
