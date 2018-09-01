class AddStepOrderToSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :steps, :step_order, :integer

    Recipe.all.each do |recipe|
      recipe.parts.each do |part|
        part.steps.each_with_index do |step, index|
          step.update_attribute(:step_order, index += 1)
        end
      end
    end

    change_column_null :steps, :step_order, false
  end
end
