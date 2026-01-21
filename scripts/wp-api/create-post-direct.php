<?php
/**
 * Direct WordPress Post Creation Script
 *
 * Creates a post directly through WordPress functions
 * Use this when REST API authentication is not available
 */

define('WP_USE_THEMES', false);
require('/var/www/html/wp-load.php');

// Get post data from command line arguments
$title = $argv[1] ?? '';
$content = $argv[2] ?? '';
$status = $argv[3] ?? 'draft';
$categories = !empty($argv[4]) ? array_map('intval', explode(',', $argv[4])) : [1];

if (empty($title)) {
    echo "Error: Title is required\n";
    echo "Usage: php create-post-direct.php \"Title\" \"<p>Content</p>\" \"publish\" \"1,3\"\n";
    exit(1);
}

// Create post
$post_data = [
    'post_title'    => $title,
    'post_content'  => $content,
    'post_status'   => $status,
    'post_author'   => 1, // Admin user
    'post_category' => $categories,
    'post_type'     => 'post'
];

$post_id = wp_insert_post($post_data, true);

if (is_wp_error($post_id)) {
    echo "Error creating post: " . $post_id->get_error_message() . "\n";
    exit(1);
}

// Get post details
$post = get_post($post_id);
$permalink = get_permalink($post_id);

echo "✓ Post created successfully!\n";
echo "  ID: " . $post_id . "\n";
echo "  Title: " . $post->post_title . "\n";
echo "  Status: " . $post->post_status . "\n";
echo "  Link: " . $permalink . "\n";

// Save result to JSON
$result = [
    'id' => $post_id,
    'title' => $post->post_title,
    'link' => $permalink,
    'status' => $post->post_status,
    'date' => $post->post_date,
    'categories' => $categories
];

file_put_contents('created-post.json', json_encode($result, JSON_PRETTY_PRINT));
echo "\nPost details saved to: created-post.json\n";
echo "\nRollback command:\n";
echo "  docker-compose exec wordpress php -r \"require('/var/www/html/wp-load.php'); wp_delete_post($post_id, true);\"\n";
