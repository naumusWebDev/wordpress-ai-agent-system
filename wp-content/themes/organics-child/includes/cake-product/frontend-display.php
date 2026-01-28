<?php
/**
 * Cake Product Frontend Display
 *
 * Displays size selector and dietary options on product pages
 * with live price calculation.
 *
 * @package Organics_Child
 * @since 1.0.0
 */

// Exit if accessed directly.
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}


/**
 * Display cake product configurator on single product page.
 *
 * Injects size selector and options before the add to cart button.
 *
 * @since 1.0.0
 */
function organics_child_display_cake_configurator() {
	global $product;

	if ( ! $product ) {
		return;
	}

	// Check if this is a cake product.
	$is_cake_product = get_post_meta( $product->get_id(), '_is_cake_product', true );

	if ( 'yes' !== $is_cake_product ) {
		return;
	}

	// Get product configuration.
	$cake_sizes   = get_post_meta( $product->get_id(), '_cake_sizes', true );
	$cake_options = get_post_meta( $product->get_id(), '_cake_options', true );

	// Validate configuration exists.
	if ( empty( $cake_sizes ) || ! is_array( $cake_sizes ) ) {
		return;
	}

	// Prepare data for JavaScript.
	$js_data = array(
		'sizes'   => $cake_sizes,
		'options' => ! empty( $cake_options ) ? $cake_options : array(),
		'currency_symbol' => get_woocommerce_currency_symbol(),
		'currency_position' => get_option( 'woocommerce_currency_pos', 'left' ),
	);

	?>
	<div class="organics-cake-configurator" data-config="<?php echo esc_attr( wp_json_encode( $js_data ) ); ?>">

		<!-- Size Selector -->
		<div class="cake-size-selector">
			<h3 class="cake-section-title"><?php esc_html_e( 'Select Size', 'organics-child' ); ?> <span class="required">*</span></h3>

			<div class="cake-sizes-wrapper">
				<?php foreach ( $cake_sizes as $size_key => $size_data ) : ?>
					<?php
					$servings = isset( $size_data['servings'] ) ? $size_data['servings'] : '';
					$price    = isset( $size_data['price'] ) ? floatval( $size_data['price'] ) : 0;
					?>
					<label class="cake-size-option">
						<input
							type="radio"
							name="cake_size"
							value="<?php echo esc_attr( $size_key ); ?>"
							data-price="<?php echo esc_attr( $price ); ?>"
							required
						/>
						<span class="cake-size-content">
							<span class="cake-size-name"><?php echo esc_html( ucfirst( $size_key ) ); ?></span>
							<span class="cake-size-servings">(<?php echo esc_html( $servings ); ?> <?php esc_html_e( 'servings', 'organics-child' ); ?>)</span>
							<span class="cake-size-price"><?php echo wc_price( $price ); ?></span>
						</span>
					</label>
				<?php endforeach; ?>
			</div>

			<p class="cake-size-error" style="display:none; color: #e2401c; font-size: 0.9em; margin-top: 10px;">
				<?php esc_html_e( 'Please select a size before adding to cart.', 'organics-child' ); ?>
			</p>
		</div>

		<?php if ( ! empty( $cake_options ) && is_array( $cake_options ) ) : ?>
			<!-- Dietary Options Selector -->
			<div class="cake-options-selector">
				<h3 class="cake-section-title"><?php esc_html_e( 'Dietary Options', 'organics-child' ); ?> <span class="optional"><?php esc_html_e( '(optional)', 'organics-child' ); ?></span></h3>

				<div class="cake-options-wrapper">
					<?php foreach ( $cake_options as $option ) : ?>
						<?php
						$option_key      = isset( $option['key'] ) ? $option['key'] : '';
						$option_label    = isset( $option['label'] ) ? $option['label'] : '';
						$option_modifier = isset( $option['modifier'] ) ? floatval( $option['modifier'] ) : 0;

						if ( empty( $option_key ) || empty( $option_label ) ) {
							continue;
						}
						?>
						<label class="cake-option-item">
							<input
								type="checkbox"
								name="cake_options[]"
								value="<?php echo esc_attr( $option_key ); ?>"
								data-modifier="<?php echo esc_attr( $option_modifier ); ?>"
							/>
							<span class="cake-option-content">
								<span class="cake-option-label"><?php echo esc_html( $option_label ); ?></span>
								<?php if ( 0 !== $option_modifier ) : ?>
									<span class="cake-option-price">
										<?php
										if ( $option_modifier > 0 ) {
											echo '+' . wc_price( $option_modifier );
										} else {
											echo wc_price( $option_modifier );
										}
										?>
									</span>
								<?php endif; ?>
							</span>
						</label>
					<?php endforeach; ?>
				</div>
			</div>
		<?php endif; ?>

		<!-- Live Price Display -->
		<div class="cake-price-display">
			<div class="cake-price-wrapper">
				<span class="cake-price-label"><?php esc_html_e( 'Total Price:', 'organics-child' ); ?></span>
				<span class="cake-price-amount" id="cake-total-price">
					<?php esc_html_e( 'Select a size', 'organics-child' ); ?>
				</span>
			</div>
		</div>

	</div>
	<?php
}
add_action( 'woocommerce_before_add_to_cart_button', 'organics_child_display_cake_configurator', 10 );

/**
 * Enqueue frontend scripts and styles for cake configurator.
 *
 * @since 1.0.0
 */
function organics_child_enqueue_cake_frontend_assets() {
	// Only load on single product pages.
	if ( ! is_product() ) {
		return;
	}

	$product_id = get_the_ID();
	if ( ! $product_id ) {
		return;
	}

	// Check if this is a cake product.
	$is_cake_product = get_post_meta( $product_id, '_is_cake_product', true );

	if ( 'yes' !== $is_cake_product ) {
		return;
	}

	// Enqueue JavaScript.
	wp_enqueue_script(
		'organics-cake-frontend-js',
		get_stylesheet_directory_uri() . '/includes/cake-product/assets/cake-configurator.js',
		array( 'jquery' ),
		'1.0.0',
		true
	);

	// Enqueue CSS.
	wp_enqueue_style(
		'organics-cake-frontend-css',
		get_stylesheet_directory_uri() . '/includes/cake-product/assets/cake-configurator.css',
		array(),
		'1.0.0'
	);

	// Localize script with translations.
	wp_localize_script(
		'organics-cake-frontend-js',
		'organicsCake',
		array(
			'selectSizeText' => __( 'Select a size', 'organics-child' ),
			'sizeRequiredError' => __( 'Please select a size before adding to cart.', 'organics-child' ),
		)
	);
}
add_action( 'wp_enqueue_scripts', 'organics_child_enqueue_cake_frontend_assets' );

/**
 * Validate cake configuration before adding to cart.
 *
 * Prevents adding to cart if size is not selected.
 *
 * @since 1.0.0
 * @param bool $passed      Validation status.
 * @param int  $product_id  Product ID.
 * @return bool
 */
function organics_child_validate_cake_add_to_cart( $passed, $product_id ) {
	// Check if this is a cake product.
	$is_cake_product = get_post_meta( $product_id, '_is_cake_product', true );

	if ( 'yes' !== $is_cake_product ) {
		return $passed;
	}

	// Validate size selection.
	if ( ! isset( $_POST['cake_size'] ) || empty( $_POST['cake_size'] ) ) {
		wc_add_notice( __( 'Please select a cake size before adding to cart.', 'organics-child' ), 'error' );
		return false;
	}

	return $passed;
}
add_filter( 'woocommerce_add_to_cart_validation', 'organics_child_validate_cake_add_to_cart', 10, 2 );
