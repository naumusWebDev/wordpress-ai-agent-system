<?php
/**
 * Child-Theme functions and definitions
 */

function my_theme_enqueue_styles() {
    wp_enqueue_style( 'parent-style', get_template_directory_uri() . '/style.css' );
    if ( is_rtl() ) {
				 wp_enqueue_style( 'parent-style-rtl', get_template_directory_uri() . '/rtl.css' );
    }
}
add_action( 'wp_enqueue_scripts', 'my_theme_enqueue_styles' );

/**
 * Load Cake Product module.
 *
 * Custom functionality for configurable cake products with sizes and dietary options.
 *
 * @since 1.0.0
 */
require_once get_stylesheet_directory() . '/includes/cake-product/admin-meta-box.php';
require_once get_stylesheet_directory() . '/includes/cake-product/cart-integration.php';
require_once get_stylesheet_directory() . '/includes/cake-product/frontend-display.php';
