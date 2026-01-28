/**
 * Cake Product Frontend Configurator
 *
 * Handles live price calculation and validation for cake products.
 *
 * @package Organics_Child
 * @since 1.0.0
 */

(function($) {
	'use strict';

	/**
	 * Cake Configurator Class
	 */
	var CakeConfigurator = {

		/**
		 * Configuration data
		 */
		config: null,

		/**
		 * Current selections
		 */
		selectedSize: null,
		selectedOptions: [],

		/**
		 * Price elements
		 */
		$priceDisplay: null,
		$sizeError: null,

		/**
		 * Initialize configurator
		 */
		init: function() {
			var $configurator = $('.organics-cake-configurator');

			if ( ! $configurator.length ) {
				return;
			}

			// Parse configuration data
			this.config = $configurator.data('config');

			if ( ! this.config ) {
				console.error('Cake configurator: Missing configuration data');
				return;
			}

			// Cache DOM elements
			this.$priceDisplay = $('#cake-total-price');
			this.$sizeError = $('.cake-size-error');

			// Bind events
			this.bindEvents();

			// Initial state
			this.updatePrice();
		},

		/**
		 * Bind event handlers
		 */
		bindEvents: function() {
			var self = this;

			// Size selection change
			$('input[name="cake_size"]').on('change', function() {
				self.selectedSize = $(this).val();
				self.$sizeError.hide();
				self.updatePrice();
			});

			// Option selection change
			$('input[name="cake_options[]"]').on('change', function() {
				self.updateSelectedOptions();
				self.updatePrice();
			});

			// Validate before add to cart
			$('form.cart').on('submit', function(e) {
				if ( ! self.validateSelection() ) {
					e.preventDefault();
					self.$sizeError.show();

					// Scroll to error
					$('html, body').animate({
						scrollTop: self.$sizeError.offset().top - 100
					}, 500);

					return false;
				}
			});
		},

		/**
		 * Update selected options array
		 */
		updateSelectedOptions: function() {
			var self = this;
			this.selectedOptions = [];

			$('input[name="cake_options[]"]:checked').each(function() {
				self.selectedOptions.push($(this).val());
			});
		},

		/**
		 * Calculate current price
		 */
		calculatePrice: function() {
			var basePrice = 0;
			var optionsPrice = 0;

			// Get base price from selected size
			if ( this.selectedSize && this.config.sizes[this.selectedSize] ) {
				basePrice = parseFloat(this.config.sizes[this.selectedSize].price) || 0;
			}

			// Calculate options price
			if ( this.selectedOptions.length > 0 && this.config.options ) {
				this.config.options.forEach(function(option) {
					if ( this.selectedOptions.indexOf(option.key) !== -1 ) {
						optionsPrice += parseFloat(option.modifier) || 0;
					}
				}.bind(this));
			}

			return basePrice + optionsPrice;
		},

		/**
		 * Format price for display
		 */
		formatPrice: function(price) {
			var formatted = price.toFixed(2);
			var symbol = this.config.currency_symbol;
			var position = this.config.currency_position || 'left';

			switch (position) {
				case 'left':
					return symbol + formatted;
				case 'right':
					return formatted + symbol;
				case 'left_space':
					return symbol + ' ' + formatted;
				case 'right_space':
					return formatted + ' ' + symbol;
				default:
					return symbol + formatted;
			}
		},

		/**
		 * Update price display
		 */
		updatePrice: function() {
			if ( ! this.selectedSize ) {
				this.$priceDisplay.html(
					'<span style="color: #999; font-style: italic;">' +
					(organicsCake.selectSizeText || 'Select a size') +
					'</span>'
				);
				return;
			}

			var totalPrice = this.calculatePrice();
			var formattedPrice = this.formatPrice(totalPrice);

			this.$priceDisplay.html(
				'<strong style="font-size: 1.2em; color: #7fb77e;">' +
				formattedPrice +
				'</strong>'
			);
		},

		/**
		 * Validate that size is selected
		 */
		validateSelection: function() {
			// Check if this is a cake product form
			if ( ! $('.organics-cake-configurator').length ) {
				return true;
			}

			// Size is required
			if ( ! this.selectedSize ) {
				return false;
			}

			return true;
		}

	};

	/**
	 * Initialize on document ready
	 */
	$(document).ready(function() {
		CakeConfigurator.init();
	});

})(jQuery);
