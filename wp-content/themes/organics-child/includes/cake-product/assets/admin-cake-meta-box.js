/**
 * Cake Product Admin Meta Box JavaScript
 *
 * Handles dynamic add/remove of dietary option rows and
 * show/hide of configuration panel.
 *
 * @package Organics_Child
 * @since 1.0.0
 */

(function($) {
	'use strict';

	/**
	 * Initialize on document ready.
	 */
	$(document).ready(function() {

		// Toggle configuration panel when checkbox changes.
		$('#organics_is_cake_product').on('change', function() {
			if ($(this).is(':checked')) {
				$('#organics-cake-config-panel').slideDown();
			} else {
				$('#organics-cake-config-panel').slideUp();
			}
		});

		// Add new option row.
		$('#organics-add-option').on('click', function(e) {
			e.preventDefault();

			var template = $('#organics-cake-option-row-template').html();
			var $tbody = $('#organics-cake-options-tbody');
			var newIndex = $tbody.find('tr').length;

			// Replace placeholder with actual index.
			var newRow = template.replace(/__INDEX__/g, newIndex);

			$tbody.append(newRow);
		});

		// Remove option row (delegated event for dynamically added rows).
		$(document).on('click', '.organics-remove-option', function(e) {
			e.preventDefault();

			var $row = $(this).closest('tr');

			// Confirm before removing (optional).
			if (confirm('Are you sure you want to remove this option?')) {
				$row.fadeOut(300, function() {
					$(this).remove();
				});
			}
		});

	});

})(jQuery);
