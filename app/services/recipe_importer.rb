class RecipeImporter
  require "open-uri"
  require "nokogiri"
  require "json"

  class ImportError < StandardError; end

  def initialize(url)
    @url = url
    @doc = nil
  end

  def import
    fetch_html
    extract_recipe_data
  end

  private

  attr_reader :url, :doc

  def fetch_html
    html = URI.open(
      url,
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
      "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      "Accept-Language" => "en-US,en;q=0.9",
      "Referer" => "https://www.google.com/"
    ).read
    @doc = Nokogiri::HTML(html)
  rescue OpenURI::HTTPError => e
    case e.io.status[0]
    when "403"
      raise ImportError, "The website is blocking automated requests. Try manually copying the recipe or use a different source."
    when "404"
      raise ImportError, "Recipe page not found. Please check the URL and try again."
    when "429"
      raise ImportError, "Too many requests. Please wait a moment and try again."
    when "500", "502", "503"
      raise ImportError, "The recipe website is temporarily unavailable. Please try again later."
    else
      raise ImportError, "Unable to access recipe page (HTTP #{e.io.status[0]}). Please try a different URL."
    end
  rescue SocketError, Errno::ECONNREFUSED, Errno::ETIMEDOUT => e
    raise ImportError, "Cannot connect to recipe website. Please check the URL and your internet connection."
  rescue URI::InvalidURIError => e
    raise ImportError, "Invalid URL format. Please check the URL and try again."
  rescue => e
    Rails.logger.error "Unexpected error fetching #{url}: #{e.class} - #{e.message}"
    raise ImportError, "Failed to fetch recipe page. Please try a different URL."
  end

  def extract_recipe_data
    # Try JSON-LD first (works for most recipe sites)
    data = extract_from_json_ld
    return data if data[:ingredients].any? || data[:instructions].any?

    # Fallback to HTML parsing
    extract_from_html
  end

  def extract_from_json_ld
    name = nil
    description = nil
    ingredients = []
    instructions = []

    json_ld_scripts = doc.css('script[type="application/ld+json"]')

    json_ld_scripts.each do |script|
      begin
        data = JSON.parse(script.text)
        recipe_data = find_recipe_in_json(data)

        if recipe_data
          name = recipe_data["name"]
          description = recipe_data["description"]
          raw_ingredients = recipe_data["recipeIngredient"] || []
          ingredients = raw_ingredients.map { |ing| parse_ingredient(ing) }
          instructions = extract_instructions_from_json(recipe_data["recipeInstructions"] || [])

          Rails.logger.info "JSON-LD found - ingredients: #{ingredients.size}, instructions: #{instructions.size}"
          break if ingredients.any? && instructions.any?
        end
      rescue JSON::ParserError => e
        Rails.logger.warn "Failed to parse JSON-LD: #{e.message}"
      end
    end

    {
      name: name,
      description: description,
      source: url,
      ingredients: ingredients,
      instructions: instructions
    }
  end

  def find_recipe_in_json(data)
    case data
    when Array
      data.find { |item| type_includes_recipe?(item["@type"]) }
    when Hash
      if type_includes_recipe?(data["@type"])
        data
      elsif data["@graph"].is_a?(Array)
        data["@graph"].find { |item| type_includes_recipe?(item["@type"]) }
      end
    end
  end

  def type_includes_recipe?(type)
    return false unless type

    if type.is_a?(Array)
      type.include?("Recipe")
    else
      type == "Recipe"
    end
  end

  def parse_ingredient(ingredient_string)
    # Remove extra whitespace
    text = ingredient_string.to_s.strip

    # Common measurement units (sorted by length descending to match longest first)
    units = %w[
      tablespoons tablespoon milliliters milliliter kilograms kilogram
      teaspoons teaspoon packages package gallons gallon quarts quart
      pints pint pounds pound ounces ounce grams gram liters liter
      cloves clove pieces piece slices slice cups cup cans can bags bag
      tbsp tsp lbs lb oz kg ml pinch dash pkg
    ]

    # Unicode fractions: ½ ⅓ ⅔ ¼ ¾ ⅕ ⅖ ⅗ ⅘ ⅙ ⅚ ⅛ ⅜ ⅝ ⅞
    # Pattern: number (digits, fractions, decimals, unicode fractions), optional unit, then item
    pattern = /^([0-9½⅓⅔¼¾⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞\/\.\s-]+)?\s*(#{units.join('|')})?\.?\s*(.+)$/i

    match = text.match(pattern)

    if match
      quantity = [ match[1], match[2] ].compact.join(" ").strip
      item = match[3].strip

      # If quantity is empty, it means no number/unit was found (like "salt to taste")
      if quantity.empty?
        { quantity: nil, item: text }
      else
        { quantity: quantity, item: item }
      end
    else
      # Fallback: entire string as item if pattern doesn't match
      { quantity: nil, item: text }
    end
  end

  def extract_instructions_from_json(instructions_data)
    instructions_data.map do |inst|
      case inst
      when Hash
        if inst["@type"] == "HowToStep"
          inst["text"]
        else
          inst["text"] || inst["itemListElement"]&.map { |step| step["text"] }
        end
      when String
        inst
      end
    end.flatten.compact
  end

  def extract_from_html
    Rails.logger.info "Falling back to HTML parsing for #{url}"

    {
      name: extract_title,
      description: extract_description,
      source: url,
      ingredients: extract_ingredients_from_html,
      instructions: extract_instructions_from_html
    }
  end

  def extract_title
    doc.at_css("h1")&.text&.strip ||
    doc.at_css("title")&.text&.split("|").first&.strip
  end

  def extract_description
    selectors = [
      ".recipe-summary",
      ".recipe-description",
      "[data-summary]",
      ".entry-content p",
      ".post-content p",
      "article p"
    ]

    selectors.each do |selector|
      element = doc.at_css(selector)
      return element.text.strip if element && element.text.strip.length > 20
    end

    nil
  end

  def extract_ingredients_from_html
    raw_ingredients = []

    # Try finding by header + list
    header = find_header_by_text(%w[Ingredients Ingredient])
    if header
      list = find_list_after_element(header)
      raw_ingredients = extract_list_items(list.css("li")) if list
      return raw_ingredients.map { |ing| parse_ingredient(ing) } if raw_ingredients.any?
    end

    # Try common ingredient selectors
    selectors = [
      ".ingredients li",
      ".recipe-ingredients li",
      "ul.ingredients li",
      '[class*="ingredient"] li',
      ".wp-block-list li"
    ]

    selectors.each do |selector|
      raw_ingredients = extract_list_items(doc.css(selector))
      break if raw_ingredients.any?
    end

    raw_ingredients.map { |ing| parse_ingredient(ing) }
  end

  def extract_instructions_from_html
    instructions = []

    # Try finding by header + list/paragraphs
    header = find_header_by_text(%w[Instructions Directions Direction Method Preparation])
    if header
      instructions = extract_content_after_header(header)
      return instructions if instructions.any?
    end

    # Try common instruction selectors
    selectors = [
      ".instructions li",
      ".directions li",
      ".recipe-directions li",
      ".recipe-instructions li",
      "ol.recipe-steps li"
    ]

    selectors.each do |selector|
      instructions = extract_list_items(doc.css(selector))
      break if instructions.any?
    end

    instructions
  end

  def find_header_by_text(text_options)
    header_tags = %w[h1 h2 h3 h4 strong]

    text_options.each do |text|
      header_tags.each do |tag|
        header = doc.at("#{tag}:contains(\"#{text}\")")
        return header if header
      end
    end

    nil
  end

  def find_list_after_element(element)
    container = element.ancestors("div").first || element.parent
    container.at("ul") || container.at("ol") ||
    element.xpath("following::ul[1]").first ||
    element.xpath("following::ol[1]").first
  end

  def extract_list_items(elements)
    return [] unless elements

    # If it's a single node (ul/ol), get its list items
    elements = elements.css("li") if elements.respond_to?(:name) && %w[ul ol].include?(elements.name)

    # Now map over the collection
    elements.map { |li| li.text.strip }.reject(&:empty?)
  end

  def extract_content_after_header(header)
    content = []
    current = header.next_element

    while current && !%w[h1 h2 h3 h4 h5 h6].include?(current.name)
      case current.name
      when "p"
        text = current.text.strip
        content << text if text.length > 10
      when "ul", "ol"
        content = extract_list_items(current.css("li"))
        break
      end
      current = current.next_element
    end

    content
  end
end
