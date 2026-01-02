import { Controller } from "@hotwired/stimulus"
import Tesseract from 'tesseract.js'

export default class extends Controller {
  static targets = ['file', 'imageDescription', 'canvas', 'hidden']

  upload(event) {
    event.preventDefault()

    const file = this.fileTarget.files[0]
    
    // Validate file type - only allow images
    if (!file.type.match('image.*')) {
      alert('Please upload an image file (JPG, PNG, GIF, etc.). PDF files are not supported.')
      this.fileTarget.value = ''  // Clear the file input
      return
    }
    
    const reader = new FileReader()

    // image preview
    reader.onload = (event) => {
      const dataURL = event.target.result
      this.hiddenTarget.classList.remove("hidden")
      this.canvasTarget.src = dataURL

      // tesseract
      Tesseract.recognize(dataURL, 'eng')
        .then(({ data }) => {
          const cleanedText = this.cleanOCRText(data.text)
          const structuredRecipe = this.parseRecipeText(cleanedText)
          this.imageDescriptionTarget.value = structuredRecipe
        })
        .catch((error) => {
          console.error('OCR Error:', error)
          alert('Failed to read text from image. Please try a different image.')
        })
    }
    
    reader.onerror = () => {
      alert('Failed to load image file. Please try again.')
    }
    
    reader.readAsDataURL(file)
  }

  cleanOCRText(text) {
    return text
      // Fix common OCR word errors
      .replace(/\bnaif\b/gi, 'half')
      .replace(/\bhat\b/gi, 'half')
      .replace(/\bsalt?\b/gi, 'salt')
      .replace(/\bsal\b/gi, 'salt')
      .replace(/\bsat\b/gi, 'salt')
      .replace(/\bust\b/gi, 'just')
      .replace(/\buntl\b/gi, 'until')
      .replace(/\bnti\b/gi, 'until')
      .replace(/\btl\b/gi, 'til')
      .replace(/\btle\b/gi, 'still')
      .replace(/\btil\b/gi, 'still')
      .replace(/\bste\b/gi, 'the')
      .replace(/\bhe\b/gi, 'the')
      .replace(/\bcost\b/gi, 'coat')
      .replace(/\bnto\b/gi, 'into')
      .replace(/\bst\b/gi, 'stir')
      .replace(/\bsi\b/gi, 'stir')
      .replace(/\bood\b/gi, 'old')
      .replace(/\bod\b/gi, 'old')
      .replace(/\boom\b/gi, 'room')
      .replace(/\bcays\b/gi, 'days')
      .replace(/\bvail\b/gi, 'vanilla')
      .replace(/\bvailta\b/gi, 'vanilla')
      .replace(/\bvanila\b/gi, 'vanilla')
      .replace(/\bbesten\b/gi, 'beaten')
      .replace(/\bbesten\b/gi, 'beaten')
      .replace(/\bcry\b/gi, 'dry')
      .replace(/\btout\b/gi, 'out')
      .replace(/\bfst\b/gi, 'first')
      .replace(/\bsale\b/gi, 'stale')
      .replace(/\bbow\b/gi, 'bowl')
      .replace(/\bish\b/gi, 'dish')
      .replace(/\bop\b/gi, 'top')
      .replace(/\bal\b/gi, 'all')
      .replace(/\beciges\b/gi, 'edges')
      .replace(/\bAd\b/gi, 'Add')
      // Fix spacing issues
      .replace(/\bf\s+you/gi, 'If you')
      .replace(/\bI\s+large\b/gi, 'In large')
      .replace(/\(If/gi, 'If')
      // Fix common OCR errors with numbers
      .replace(/\bl\b/g, '1')
      .replace(/\bO\b/g, '0')
      .replace(/(\d)\s+\/\s+(\d)/g, '$1/$2')
      .replace(/\b112\b/g, '1 1/2')  // Common OCR error for 1½
      .replace(/\b11\/2\b/g, '1 1/2')  // Another common variant
      .replace(/\b13\s+cup\b/gi, '1/3 cup')  // 13 cup -> 1/3 cup
      // Fix measurement spacing
      .replace(/(\d+)\s*([a-z]+)\b/gi, '$1 $2')
      // Fix common measurement errors
      .replace(/\btsp\b/gi, 'tsp')
      .replace(/\btbsp\b/gi, 'tbsp')
      .replace(/\bcups?\b/gi, match => match.toLowerCase())
      // Remove extra whitespace but preserve newlines
      .replace(/[^\S\n]+/g, ' ')  // Replace all whitespace except newlines with single space
      .replace(/\n\s+/g, '\n')     // Remove leading spaces from lines
      .replace(/\s+\n/g, '\n')     // Remove trailing spaces from lines
      .replace(/\n{3,}/g, '\n\n')  // Collapse multiple newlines to max 2
      .trim()
  }

  parseRecipeText(text) {
    const lines = text.split('\n').map(line => line.trim()).filter(line => line.length > 0)
    
    let ingredients = []
    let instructions = []
    let currentSection = null
    let foundIngredientsHeader = false
    
    // Filter out common recipe metadata lines (universal across recipes)
    const skipPatterns = [
      /^prep time/i,
      /^cook time/i,
      /^total time/i,
      /^course:/i,
      /^cuisine:/i,
      /^servings:/i,
      /^calories:/i,
      /^author:/i,
      /^nutrition/i,
      /^\d+\s*(mins?|minutes?|hours?|hrs?)\s*$/i,
      /^x\d+$/i,  // "x8", "1x", "2x" recipe multipliers
    ]
    
    lines.forEach(line => {
      // Detect section headers
      if (line.match(/^ingredients?:?$/i)) {
        currentSection = 'ingredients'
        foundIngredientsHeader = true
        return
      }
      if (line.match(/^(instructions?|directions?|steps?|method):?$/i)) {
        currentSection = 'instructions'
        return
      }
      
      // Skip metadata lines
      if (skipPatterns.some(pattern => pattern.test(line))) {
        return
      }
      
      // Skip very short lines or very long description lines
      if (line.length < 3 || line.length > 200) {
        return
      }
      
      // Skip lines that look like titles or descriptions (usually longer and sentence-like)
      if (!foundIngredientsHeader && line.length > 80 && !line.match(/^\d/)) {
        return
      }
      
      // Auto-detect if no section header found
      if (!currentSection) {
        if (line.match(/^[•\-\*]/) || line.match(/^[\d\u00BC-\u00BE\u2150-\u215E\/]/)) {
          currentSection = 'ingredients'
        } else if (line.match(/^\d+[\.\)]/)) {
          currentSection = 'instructions'
        }
      }
      
      // Add to appropriate section
      if (currentSection === 'ingredients') {
        let cleaned = line.replace(/^[•\-\*\+]\s*/, '')
        
        // Simple validation - just needs to have some text
        if (cleaned.length > 2 && cleaned.match(/[a-z]/i)) {
          const parsed = this.parseIngredient(cleaned)
          ingredients.push(parsed)
        }
      } else if (currentSection === 'instructions') {
        const cleaned = line.replace(/^\d+[\.\)]\s*/, '')
        // Simple validation - just needs reasonable length
        if (cleaned.length > 5) {
          instructions.push(cleaned)
        }
      } else if (foundIngredientsHeader) {
        // After finding ingredients header, default to ingredients for lines with measurements
        if (this.looksLikeIngredient(line)) {
          const cleaned = line.replace(/^[•\-\*\+\=«]\s*/, '')
          if (cleaned.length > 3) {
            ingredients.push(this.parseIngredient(cleaned))
          }
        }
      }
    })
    
    return this.formatRecipe(ingredients, instructions)
  }

  looksLikeIngredient(line) {
    const measurementWords = ['cup', 'tbsp', 'tsp', 'oz', 'lb', 'gram', 'ml', 'liter', 'pound', 'ounce', 'teaspoon', 'tablespoon']
    return measurementWords.some(word => line.toLowerCase().includes(word)) ||
           line.match(/^[\d\u00BC-\u00BE\u2150-\u215E\/]/)
  }

  parseIngredient(line) {
    // Match quantity (numbers, fractions) and unit, then item
    const units = ['tablespoons?', 'teaspoons?', 'cups?', 'ounces?', 'pounds?', 'grams?', 'liters?', 
                   'tbsp', 'tsp', 'oz', 'lb', 'g', 'ml', 'kg', 'pinch', 'dash', 'cloves?', 'cans?']
    
    const pattern = new RegExp(`^([\\d\\u00BC-\\u00BE\\u2150-\\u215E\\/\\s-]+)?\\s*(${units.join('|')})?\\s*(.+)$`, 'i')
    const match = line.match(pattern)
    
    if (match) {
      const quantity = [match[1], match[2]].filter(Boolean).join(' ').trim()
      const item = match[3].trim()
      
      if (quantity) {
        return `${quantity} ${item}`
      }
      return item
    }
    
    return line
  }

  formatRecipe(ingredients, instructions) {
    let output = ''
    
    if (ingredients.length > 0) {
      output += 'INGREDIENTS:\n\n'
      ingredients.forEach(ing => {
        output += `${ing}\n`
      })
    }
    
    if (instructions.length > 0) {
      if (output) output += '\n'  // Add spacing if we had ingredients
      output += 'INSTRUCTIONS:\n\n'
      instructions.forEach((inst, index) => {
        output += `${index + 1}. ${inst}\n\n`
      })
    }
    
    // If no content found, return helpful message
    if (output === '') {
      return 'No recipe content found. Please try a clearer image or check that the image contains a recipe.'
    }
    
    return output.trim()
  }
}
