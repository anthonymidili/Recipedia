class StepDescriptionToActionText < ActiveRecord::Migration[7.0]
  include ActionView::Helpers::TextHelper
  def change
    rename_column :steps, :description, :old_description
    Step.all.each do |step|
      step.update_attribute(:description, simple_format(step.old_description))
    end
    remove_column :steps, :old_description
  end
end
