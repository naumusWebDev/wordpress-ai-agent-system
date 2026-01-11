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
