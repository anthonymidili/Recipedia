class RecipeImportJob < ApplicationJob
  queue_as :default

  def perform(import_id)
    import = Import.find(import_id)

    begin
      import.update!(status: "processing")

      importer = RecipeImporter.new(import.url)
      data = importer.import

      # Validate that we found recipe content
      if data[:ingredients].empty? && data[:instructions].empty?
        import.update!(
          status: "failed",
          error_message: "No recipe ingredients or instructions found on this page. Please make sure you're importing from a recipe page, not an article or review page."
        )
        return
      end

      # Format ingredients with quantity and item separated by pipe
      formatted_ingredients = data[:ingredients].map do |ing|
        if ing[:quantity].present?
          "#{ing[:quantity]}|#{ing[:item]}"
        else
          "|#{ing[:item]}"
        end
      end

      # Update the import record with the scraped data
      import.update!(
        status: "completed",
        title: data[:name],
        description: data[:description],
        source: data[:source],
        ingredients: formatted_ingredients.join("\n"),
        instructions: data[:instructions].join("\n"),
        error_message: nil
      )

      # Send notification to user that import is complete
      RecipeChannel.broadcast_to(
        import.user,
        {
          type: "import_complete",
          import_id: import.id,
          message: "Recipe imported successfully! Please review and save."
        }
      )

    rescue RecipeImporter::ImportError => e
      Rails.logger.warn "Import failed for #{import.url}: #{e.message}"
      import.update!(
        status: "failed",
        error_message: e.message
      )
    rescue => e
      Rails.logger.error "Unexpected import error for #{import.url}: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.first(20).join("\n")
      import.update!(
        status: "failed",
        error_message: "Failed to import recipe: #{e.message}"
      )
    end
  end
end
