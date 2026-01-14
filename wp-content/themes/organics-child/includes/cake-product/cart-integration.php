<?php
/**
 * Cake Product Cart Integration
 *
 * Handles price calculation, cart item data, and order persistence
 * for cake products with dynamic size and option selections.
 *
 * @package Organics_Child
 * @since 1.0.0
 */

// Exit if accessed directly.
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Capture cake configuration when product is added to cart.
 *
 * Validates user selections, calculates final price, and stores
 * configuration data in cart item meta.
 *
 * @since 1.0.0
 * @param array $cart_item_data Cart item data.
 * @param int   $product_id     Product ID.
 * @param int   $variation_id   Variation ID (not used for simple products).
 * @return array Modified cart item data.
 */
function organics_child_add_cake_data_to_cart( $cart_item_data, $product_id, $variation_id ) {
	// Check if this is a cake product.
	$is_cake_product = get_post_meta( $product_id, '_is_cake_product', true );

	if ( 'yes' !== $is_cake_product ) {
		return $cart_item_data;
	}

	// Get product configuration.
	$cake_sizes   = get_post_meta( $product_id, '_cake_sizes', true );
	$cake_options = get_post_meta( $product_id, '_cake_options', true );

	// Validate size selection (required).
	if ( ! isset( $_POST['cake_size'] ) || empty( $_POST['cake_size'] ) ) {
		// Size is required - throw error.
		wc_add_notice( __( 'Please select a cake size before adding to cart.', 'organics-child' ), 'error' );
		return $cart_item_data;
	}

	$selected_size = sanitize_text_field( $_POST['cake_size'] );

	// Validate size exists in product configuration.
	if ( ! isset( $cake_sizes[ $selected_size ] ) ) {
		wc_add_notice( __( 'Invalid cake size selected.', 'organics-child' ), 'error' );
		return $cart_item_data;
	}

	// Get base price from size.
	$base_price = floatval( $cake_sizes[ $selected_size ]['price'] );
	$servings   = $cake_sizes[ $selected_size ]['servings'];

	// Store size data.
	$cart_item_data['cake_size'] = $selected_size;
	$cart_item_data['cake_size_label'] = ucfirst( $selected_size ) . ' (' . $servings . ' ' . __( 'servings', 'organics-child' ) . ')';

	// Process selected options (optional).
	$selected_options = array();
	$options_labels   = array();
	$options_price    = 0;

	if ( isset( $_POST['cake_options'] ) && is_array( $_POST['cake_options'] ) ) {
		foreach ( $_POST['cake_options'] as $option_key ) {
			$option_key = sanitize_text_field( $option_key );

			// Find option in product configuration.
			foreach ( $cake_options as $option ) {
				if ( $option['key'] === $option_key ) {
					$selected_options[] = $option_key;
					$options_labels[]   = $option['label'];
					$options_price     += floatval( $option['modifier'] );
					break;
				}
			}
		}
	}

	// Store options data.
	$cart_item_data['cake_options'] = $selected_options;
	$cart_item_data['cake_options_label'] = ! empty( $options_labels ) ? implode( ', ', $options_labels ) : __( 'None', 'organics-child' );

	// Calculate final price.
	$final_price = $base_price + $options_price;

	// Store calculated price.
	$cart_item_data['cake_base_price']    = $base_price;
	$cart_item_data['cake_options_price'] = $options_price;
	$cart_item_data['cake_final_price']   = $final_price;

	// Make cart item unique (prevent merging if different configurations).
	$cart_item_data['unique_key'] = md5( json_encode( $cart_item_data ) );

	return $cart_item_data;
}
add_filter( 'woocommerce_add_cart_item_data', 'organics_child_add_cake_data_to_cart', 10, 3 );

/**
 * Override product price in cart based on cake configuration.
 *
 * @since 1.0.0
 * @param WC_Cart $cart Cart object.
 */
function organics_child_set_cake_cart_item_price( $cart ) {
	if ( is_admin() && ! defined( 'DOING_AJAX' ) ) {
		return;
	}

	foreach ( $cart->get_cart() as $cart_item_key => $cart_item ) {
		// Check if this cart item has cake configuration.
		if ( isset( $cart_item['cake_final_price'] ) ) {
			// Set the product price to the calculated price.
			$cart_item['data']->set_price( $cart_item['cake_final_price'] );
		}
	}
}
add_action( 'woocommerce_before_calculate_totals', 'organics_child_set_cake_cart_item_price', 10, 1 );

/**
 * Display cake configuration in cart and checkout.
 *
 * @since 1.0.0
 * @param array $item_data Item data to display.
 * @param array $cart_item Cart item data.
 * @return array Modified item data.
 */
function organics_child_display_cake_cart_item_data( $item_data, $cart_item ) {
	// Display size selection.
	if ( isset( $cart_item['cake_size_label'] ) ) {
		$item_data[] = array(
			'key'   => __( 'Size', 'organics-child' ),
			'value' => $cart_item['cake_size_label'],
		);
	}

	// Display selected options.
	if ( isset( $cart_item['cake_options_label'] ) ) {
		$item_data[] = array(
			'key'   => __( 'Dietary Options', 'organics-child' ),
			'value' => $cart_item['cake_options_label'],
		);
	}

	return $item_data;
}
add_filter( 'woocommerce_get_item_data', 'organics_child_display_cake_cart_item_data', 10, 2 );

/**
 * Save cake configuration to order item meta when order is created.
 *
 * @since 1.0.0
 * @param WC_Order_Item_Product $item          Order item object.
 * @param string                $cart_item_key Cart item key.
 * @param array                 $values        Cart item values.
 * @param WC_Order              $order         Order object.
 */
function organics_child_save_cake_order_item_meta( $item, $cart_item_key, $values, $order ) {
	// Save size configuration.
	if ( isset( $values['cake_size'] ) ) {
		$item->add_meta_data( '_cake_size', $values['cake_size'], true );
		$item->add_meta_data( __( 'Size', 'organics-child' ), $values['cake_size_label'], true );
	}

	// Save options configuration.
	if ( isset( $values['cake_options'] ) ) {
		$item->add_meta_data( '_cake_options', $values['cake_options'], true );
		$item->add_meta_data( __( 'Dietary Options', 'organics-child' ), $values['cake_options_label'], true );
	}

	// Save pricing breakdown (for admin reference).
	if ( isset( $values['cake_base_price'] ) ) {
		$item->add_meta_data( '_cake_base_price', $values['cake_base_price'], true );
	}

	if ( isset( $values['cake_options_price'] ) ) {
		$item->add_meta_data( '_cake_options_price', $values['cake_options_price'], true );
	}

	if ( isset( $values['cake_final_price'] ) ) {
		$item->add_meta_data( '_cake_final_price', $values['cake_final_price'], true );
	}
}
add_action( 'woocommerce_checkout_create_order_line_item', 'organics_child_save_cake_order_item_meta', 10, 4 );

/**
 * Display cake configuration in order admin and emails.
 *
 * Hide internal meta keys (those starting with _) from customer view,
 * but keep human-readable labels visible.
 *
 * @since 1.0.0
 * @param bool   $display Whether to display the meta.
 * @param object $meta    Meta object.
 * @param object $item    Order item object.
 * @return bool
 */
function organics_child_hide_cake_internal_meta( $display, $meta, $item ) {
	// Hide internal meta keys from customer view.
	$hidden_keys = array(
		'_cake_size',
		'_cake_options',
		'_cake_base_price',
		'_cake_options_price',
		'_cake_final_price',
	);

	if ( in_array( $meta->key, $hidden_keys, true ) ) {
		return false;
	}

	return $display;
}
add_filter( 'woocommerce_order_item_display_meta_key', 'organics_child_hide_cake_internal_meta', 10, 3 );
