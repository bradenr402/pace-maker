import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="image-preview"
export default class extends Controller {
  static targets = ['output', 'input', 'clearBtn', 'previewSection'];

  readURL() {
    if (this.inputTarget.files && this.inputTarget.files[0]) {
      this.clearBtnTarget.classList.remove('hidden');
      this.outputTarget.classList.remove('hidden');

      const reader = new FileReader();

      reader.onload = () => {
        this.outputTarget.src = reader.result;
      };

      reader.readAsDataURL(this.inputTarget.files[0]);
    } else {
      this.clearBtnTarget.classList.add('hidden');
      this.outputTarget.classList.add('hidden');
    }
  }

  clearUpload() {
    this.inputTarget.value = null;
    this.outputTarget.src = null;
    this.clearBtnTarget.classList.add('hidden');
    this.outputTarget.classList.add('hidden');
  }

  selectCheckbox(event) {
    if (event.currentTarget.checked) {
      this.clearBtnTarget.classList.add('hidden');
      this.inputTarget.classList.add('hidden');
    } else {
      this.inputTarget.classList.remove('hidden');
      this.clearBtnTarget.classList.remove('hidden');
    }
  }
}
