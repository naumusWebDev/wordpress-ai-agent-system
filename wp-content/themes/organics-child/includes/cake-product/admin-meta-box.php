<?php
/**
 * Cake Product Admin Meta Box
 *
 * Adds a meta box to the WooCommerce product edit screen for configuring
 * cake products with sizes and dietary options.
 *
 * @package Organics_Child
 * @since 1.0.0
 */

// Exit if accessed directly.
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Register the Cake Product meta box.
 *
 * @since 1.0.0
 */
function organics_child_add_cake_meta_box() {
	add_meta_box(
		'organics_cake_product_config',
		__( 'Cake Product Configuration', 'organics-child' ),
		'organics_child_render_cake_meta_box',
		'product',
		'normal',
		'high'
	);
}
add_action( 'add_meta_boxes', 'organics_child_add_cake_meta_box' );
add_action( 'add_meta_boxes_product', 'organics_child_add_cake_meta_box' );

/**
 * Render the Cake Product meta box content.
 *
 * @since 1.0.0
 * @param WP_Post $post The current post object.
 */
function organics_child_render_cake_meta_box( $post ) {
	// Add nonce for security.
	wp_nonce_field( 'organics_cake_product_meta_box', 'organics_cake_product_nonce' );

	// Get existing meta values.
	$is_cake_product = get_post_meta( $post->ID, '_is_cake_product', true );
	$cake_sizes      = get_post_meta( $post->ID, '_cake_sizes', true );
	$cake_options    = get_post_meta( $post->ID, '_cake_options', true );

	// Set defaults if empty.
	if ( empty( $cake_sizes ) ) {
		$cake_sizes = array(
			'small'  => array( 'servings' => 6, 'price' => '' ),
			'medium' => array( 'servings' => 12, 'price' => '' ),
			'large'  => array( 'servings' => 24, 'price' => '' ),
		);
	}

	// Default options if empty (suggestions).
	if ( empty( $cake_options ) && 'yes' !== $is_cake_product ) {
		$cake_options = array(
			array( 'key' => 'vegan', 'label' => 'Vegan', 'modifier' => '3.00' ),
			array( 'key' => 'dairy_free', 'label' => 'Dairy-free', 'modifier' => '2.00' ),
			array( 'key' => 'nut_free', 'label' => 'Nut-free', 'modifier' => '2.00' ),
			array( 'key' => 'wheat_free', 'label' => 'Wheat-free', 'modifier' => '2.50' ),
			array( 'key' => 'sugar_free', 'label' => 'Sugar-free', 'modifier' => '2.00' ),
		);
	} elseif ( ! is_array( $cake_options ) ) {
		$cake_options = array();
	}

	?>
	<div class="organics-cake-product-wrapper">
		<p>
			<label>
				<input type="checkbox" name="organics_is_cake_product" id="organics_is_cake_product" value="yes" <?php checked( $is_cake_product, 'yes' ); ?> />
				<strong><?php esc_html_e( 'Enable Cake Product Configuration', 'organics-child' ); ?></strong>
			</label>
		</p>

		<div id="organics-cake-config-panel" style="<?php echo ( 'yes' === $is_cake_product ) ? '' : 'display:none;'; ?>">

			<!-- Size Pricing Table -->
			<div class="organics-cake-sizes-section">
				<h4><?php esc_html_e( 'Cake Sizes & Pricing', 'organics-child' ); ?></h4>
				<table class="widefat organics-cake-sizes-table">
					<thead>
						<tr>
							<th><?php esc_html_e( 'Size', 'organics-child' ); ?></th>
							<th><?php esc_html_e( 'Servings', 'organics-child' ); ?></th>
							<th><?php esc_html_e( 'Price', 'organics-child' ); ?> (<?php echo esc_html( get_woocommerce_currency_symbol() ); ?>)</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td><strong><?php esc_html_e( 'Small', 'organics-child' ); ?></strong></td>
							<td><?php echo esc_html( $cake_sizes['small']['servings'] ); ?> <?php esc_html_e( 'servings', 'organics-child' ); ?></td>
							<td>
								<input type="number" name="organics_cake_size_price[small]" value="<?php echo esc_attr( $cake_sizes['small']['price'] ); ?>" step="0.01" min="0" class="small-text" />
							</td>
						</tr>
						<tr>
							<td><strong><?php esc_html_e( 'Medium', 'organics-child' ); ?></strong></td>
							<td><?php echo esc_html( $cake_sizes['medium']['servings'] ); ?> <?php esc_html_e( 'servings', 'organics-child' ); ?></td>
							<td>
								<input type="number" name="organics_cake_size_price[medium]" value="<?php echo esc_attr( $cake_sizes['medium']['price'] ); ?>" step="0.01" min="0" class="small-text" />
							</td>
						</tr>
						<tr>
							<td><strong><?php esc_html_e( 'Large', 'organics-child' ); ?></strong></td>
							<td><?php echo esc_html( $cake_sizes['large']['servings'] ); ?> <?php esc_html_e( 'servings', 'organics-child' ); ?></td>
							<td>
								<input type="number" name="organics_cake_size_price[large]" value="<?php echo esc_attr( $cake_sizes['large']['price'] ); ?>" step="0.01" min="0" class="small-text" />
							</td>
						</tr>
					</tbody>
				</table>
			</div>

			<!-- Dietary Options Builder -->
			<div class="organics-cake-options-section">
				<h4><?php esc_html_e( 'Dietary Options', 'organics-child' ); ?></h4>
				<table class="widefat organics-cake-options-table">
					<thead>
						<tr>
							<th><?php esc_html_e( 'Option Label', 'organics-child' ); ?></th>
							<th><?php esc_html_e( 'Price Modifier', 'organics-child' ); ?> (<?php echo esc_html( get_woocommerce_currency_symbol() ); ?>)</th>
							<th><?php esc_html_e( 'Action', 'organics-child' ); ?></th>
						</tr>
					</thead>
					<tbody id="organics-cake-options-tbody">
						<?php
						if ( ! empty( $cake_options ) ) {
							foreach ( $cake_options as $index => $option ) {
								?>
								<tr class="organics-cake-option-row">
									<td>
										<input type="text" name="organics_cake_options[<?php echo esc_attr( $index ); ?>][label]" value="<?php echo esc_attr( $option['label'] ); ?>" class="regular-text" placeholder="<?php esc_attr_e( 'e.g., Vegan', 'organics-child' ); ?>" />
									</td>
									<td>
										<input type="number" name="organics_cake_options[<?php echo esc_attr( $index ); ?>][modifier]" value="<?php echo esc_attr( $option['modifier'] ); ?>" step="0.01" class="small-text" placeholder="0.00" />
									</td>
									<td>
										<button type="button" class="button organics-remove-option"><?php esc_html_e( 'Remove', 'organics-child' ); ?></button>
									</td>
								</tr>
								<?php
							}
						}
						?>
					</tbody>
				</table>
				<p>
					<button type="button" id="organics-add-option" class="button button-secondary"><?php esc_html_e( '+ Add Option', 'organics-child' ); ?></button>
				</p>
				<p class="description">
					<?php esc_html_e( 'Add dietary options that customers can select. Price modifiers can be positive (additional cost) or negative (discount).', 'organics-child' ); ?>
				</p>
			</div>

		</div>
	</div>

	<!-- Hidden template for new option rows -->
	<script type="text/template" id="organics-cake-option-row-template">
		<tr class="organics-cake-option-row">
			<td>
				<input type="text" name="organics_cake_options[__INDEX__][label]" value="" class="regular-text" placeholder="<?php esc_attr_e( 'e.g., Vegan', 'organics-child' ); ?>" />
			</td>
			<td>
				<input type="number" name="organics_cake_options[__INDEX__][modifier]" value="" step="0.01" class="small-text" placeholder="0.00" />
			</td>
			<td>
				<button type="button" class="button organics-remove-option"><?php esc_html_e( 'Remove', 'organics-child' ); ?></button>
			</td>
		</tr>
	</script>
	<?php
}

/**
 * Save the Cake Product meta box data.
 *
 * @since 1.0.0
 * @param int $post_id The post ID.
 */
function organics_child_save_cake_meta_box( $post_id ) {
	// Check nonce.
	if ( ! isset( $_POST['organics_cake_product_nonce'] ) || ! wp_verify_nonce( $_POST['organics_cake_product_nonce'], 'organics_cake_product_meta_box' ) ) {
		return;
	}

	// Check autosave.
	if ( defined( 'DOING_AUTOSAVE' ) && DOING_AUTOSAVE ) {
		return;
	}

	// Check user permissions.
	if ( ! current_user_can( 'edit_product', $post_id ) ) {
		return;
	}

	// Save "Enable Cake Product" checkbox.
	$is_cake_product = isset( $_POST['organics_is_cake_product'] ) && 'yes' === $_POST['organics_is_cake_product'] ? 'yes' : 'no';
	update_post_meta( $post_id, '_is_cake_product', $is_cake_product );

	// Only save config data if cake product is enabled.
	if ( 'yes' === $is_cake_product ) {
		// Save size pricing.
		$sizes = array(
			'small'  => array( 'servings' => 6, 'price' => 0 ),
			'medium' => array( 'servings' => 12, 'price' => 0 ),
			'large'  => array( 'servings' => 24, 'price' => 0 ),
		);

		if ( isset( $_POST['organics_cake_size_price'] ) && is_array( $_POST['organics_cake_size_price'] ) ) {
			foreach ( array( 'small', 'medium', 'large' ) as $size ) {
				if ( isset( $_POST['organics_cake_size_price'][ $size ] ) ) {
					$price = sanitize_text_field( $_POST['organics_cake_size_price'][ $size ] );
					$sizes[ $size ]['price'] = '' !== $price ? floatval( $price ) : '';
				}
			}
		}

		update_post_meta( $post_id, '_cake_sizes', $sizes );

		// Save dietary options.
		$options = array();

		if ( isset( $_POST['organics_cake_options'] ) && is_array( $_POST['organics_cake_options'] ) ) {
			foreach ( $_POST['organics_cake_options'] as $option ) {
				$label    = isset( $option['label'] ) ? sanitize_text_field( $option['label'] ) : '';
				$modifier = isset( $option['modifier'] ) ? sanitize_text_field( $option['modifier'] ) : '';

				// Only save if label is not empty.
				if ( '' !== $label ) {
					$options[] = array(
						'key'      => sanitize_title( $label ),
						'label'    => $label,
						'modifier' => '' !== $modifier ? floatval( $modifier ) : 0,
					);
				}
			}
		}

		update_post_meta( $post_id, '_cake_options', $options );
	} else {
		// If disabled, optionally clear meta (or keep for when re-enabled).
		// For now, we'll keep the data.
	}
}
add_action( 'save_post_product', 'organics_child_save_cake_meta_box' );

/**
 * Enqueue admin scripts and styles for Cake Product meta box.
 *
 * @since 1.0.0
 * @param string $hook The current admin page hook.
 */
function organics_child_enqueue_cake_admin_assets( $hook ) {
	// Only load on product edit screen.
	if ( 'post.php' !== $hook && 'post-new.php' !== $hook ) {
		return;
	}

	$screen = get_current_screen();
	if ( ! $screen || 'product' !== $screen->post_type ) {
		return;
	}

	// Enqueue JavaScript.
	wp_enqueue_script(
		'organics-cake-admin-js',
		get_stylesheet_directory_uri() . '/includes/cake-product/assets/admin-cake-meta-box.js',
		array( 'jquery' ),
		'1.0.0',
		true
	);

	// Enqueue CSS.
	wp_enqueue_style(
		'organics-cake-admin-css',
		get_stylesheet_directory_uri() . '/includes/cake-product/assets/admin-cake-meta-box.css',
		array(),
		'1.0.0'
	);
}
add_action( 'admin_enqueue_scripts', 'organics_child_enqueue_cake_admin_assets' );
