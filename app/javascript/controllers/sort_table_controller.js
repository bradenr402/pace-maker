import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="sort-table"
export default class extends Controller {
  static targets = ['table', 'th', 'defaultSort'];

  connect() {
    this.sortColumnIndex = null;
    this.sortAscending = true;

    this.autoSort();
  }

  autoSort() {
    if (this.hasDefaultSortTarget)
      this.sort({ currentTarget: this.defaultSortTarget });
  }

  sort(event) {
    const header = event.currentTarget;
    const columnIndex = Array.from(header.parentElement.children).indexOf(
      header
    );
    const isNumeric = header.dataset.numeric === 'true';

    // Set initial sort direction for numeric columns to descending (greatest to least)
    if (this.sortColumnIndex === columnIndex) {
      this.sortAscending = !this.sortAscending;
    } else {
      this.sortColumnIndex = columnIndex;
      this.sortAscending = !isNumeric; // Numeric columns start descending
    }

    const tbody = this.tableTarget.querySelector('tbody');
    const rows = Array.from(tbody.querySelectorAll('tr'));

    const sortedRows = rows.sort((a, b) => {
      const cellA = a.children[columnIndex].innerText.trim();
      const cellB = b.children[columnIndex].innerText.trim();

      // Handle numeric and string sorting
      if (isNumeric) {
        const numA = parseFloat(cellA.replace(/,/g, '')) || 0;
        const numB = parseFloat(cellB.replace(/,/g, '')) || 0;
        return this.sortAscending ? numA - numB : numB - numA;
      } else {
        return this.sortAscending
          ? cellA.localeCompare(cellB)
          : cellB.localeCompare(cellA);
      }
    });

    // Clear and re-append sorted rows
    while (tbody.firstChild) {
      tbody.removeChild(tbody.firstChild);
    }
    sortedRows.forEach((row) => tbody.appendChild(row));

    // Update sort indicator
    this.updateSortIndicator(header);
  }

  updateSortIndicator(header) {
    // Hide all icons initially
    this.thTargets.forEach((th) => {
      th.querySelector('svg').classList.add('hidden');
    });

    // Show the icon for the currently sorted column
    const icon = header.querySelector('svg');
    icon.classList.remove('hidden');

    // Rotate the arrow if sorting in descending order
    if (!this.sortAscending) {
      icon.classList.add('rotate-180');
    } else {
      icon.classList.remove('rotate-180');
    }
  }
}
