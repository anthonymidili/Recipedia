import { Controller } from "@hotwired/stimulus"
import Tesseract from 'tesseract.js'

export default class extends Controller {
  static targets = ['file', 'imageDescription', 'canvas', 'hidden']

  upload(event) {
    event.preventDefault()

    const file = this.fileTarget.files[0]
    const reader = new FileReader()

    // image preview
    reader.onload = (event) => {
      const dataURL = event.target.result
      // console.log('Data URL:', dataURL)
      this.hiddenTarget.classList.remove("hidden")
      this.canvasTarget.src = reader.result

      // tesseract
      reader.onload = (event) => {
        Tesseract.recognize(event.target.result, 'eng')
          .then(({ data }) => {
            // console.log('Data to TEXT:', data)
            this.imageDescriptionTarget.value = data.text
          }
        )
      }
      reader.readAsArrayBuffer(file) // tesseract output
    }
    reader.readAsDataURL(file) // image preview
  }
}
