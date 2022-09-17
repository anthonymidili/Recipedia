class MigrateReviewBodyToActionText < ActiveRecord::Migration[7.0]
  include ActionView::Helpers::TextHelper
  def change
    rename_column :reviews, :body, :old_body
    Review.all.each do |review|
      review.update_attribute(:body, simple_format(review.old_body))
    end
    remove_column :reviews, :old_body
  end
end
