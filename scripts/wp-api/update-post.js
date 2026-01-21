#!/usr/bin/env node

/**
 * WordPress REST API - Update Post Script
 *
 * Updates an existing post in WordPress via REST API
 *
 * @version 1.0.0
 * @author Scripter Agent
 */

const https = require('https');
const http = require('http');
const fs = require('fs');

// Parse command line arguments
function parseArgs() {
  const args = process.argv.slice(2);
  const options = {
    id: null,
    title: null,
    content: null,
    excerpt: null,
    status: null,
    categories: null,
    tags: null,
    featured_media: null,
    meta: {},
    file: null,
    output: null
  };

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];

    if (arg === '--help' || arg === '-h') {
      printHelp();
      process.exit(0);
    }

    if (arg.startsWith('--')) {
      const [key, value] = arg.slice(2).split('=');

      switch (key) {
        case 'id':
          options.id = parseInt(value || args[++i]);
          break;
        case 'title':
          options.title = value || args[++i];
          break;
        case 'content':
          options.content = value || args[++i];
          break;
        case 'excerpt':
          options.excerpt = value || args[++i];
          break;
        case 'status':
          options.status = value || args[++i];
          break;
        case 'categories':
          options.categories = (value || args[++i]).split(',').map(c => parseInt(c.trim()));
          break;
        case 'tags':
          options.tags = (value || args[++i]).split(',').map(t => parseInt(t.trim()));
          break;
        case 'featured-media':
          options.featured_media = parseInt(value || args[++i]);
          break;
        case 'file':
          options.file = value || args[++i];
          break;
        case 'output':
          options.output = value || args[++i];
          break;
        default:
          // Handle meta fields
          if (key.startsWith('meta-')) {
            const metaKey = key.replace('meta-', '');
            options.meta[metaKey] = value || args[++i];
          }
      }
    }
  }

  return options;
}

function printHelp() {
  console.log(`
WordPress REST API - Update Post Script

Usage:
  node update-post.js --id=ID [options]

Options:
  --id=ID                        Post ID (required)
  --title=TITLE                  Post title
  --content=CONTENT              Post content in HTML
  --excerpt=TEXT                 Post excerpt
  --status=STATUS                Post status: draft, publish, pending, private
  --categories=IDS               Comma-separated category IDs
  --tags=IDS                     Comma-separated tag IDs
  --featured-media=ID            Featured image media ID
  --meta-KEY=VALUE               Update custom meta field
  --file=FILE                    Read update data from JSON file
  --output=FILE                  Save updated post info to JSON file
  -h, --help                     Show this help

Environment Variables:
  WP_API_BASE_URL                WordPress REST API base URL (required)
  WP_API_USER                    WordPress username (required)
  WP_API_PASSWORD                Application Password (required)

Examples:
  # Update post title and content
  node update-post.js --id=3712 \\
    --title="Nuevo título" \\
    --content="<p>Nuevo contenido</p>"

  # Add featured image to post
  node update-post.js --id=3712 --featured-media=123

  # Update from JSON file
  node update-post.js --id=3712 --file=post-update.json

JSON File Format (--file option):
  {
    "title": "Updated Post Title",
    "content": "<p>Updated content</p>",
    "featured_media": 123,
    "status": "publish"
  }
`);
}

// Load configuration from environment
function loadConfig() {
  const config = {
    baseUrl: process.env.WP_API_BASE_URL,
    user: process.env.WP_API_USER,
    password: process.env.WP_API_PASSWORD
  };

  if (!config.baseUrl) {
    console.error('Error: WP_API_BASE_URL environment variable is required');
    process.exit(1);
  }

  if (!config.user || !config.password) {
    console.error('Error: WP_API_USER and WP_API_PASSWORD environment variables are required');
    process.exit(1);
  }

  return config;
}

// Make HTTP request
function makeRequest(url, auth, method, postData) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const protocol = urlObj.protocol === 'https:' ? https : http;

    const authHeader = 'Basic ' + Buffer.from(auth).toString('base64');

    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port || (urlObj.protocol === 'https:' ? 443 : 80),
      path: urlObj.pathname,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authHeader,
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    const req = protocol.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          if (res.statusCode >= 200 && res.statusCode < 300) {
            resolve(json);
          } else {
            reject(new Error(`HTTP ${res.statusCode}: ${json.message || data}`));
          }
        } catch (e) {
          reject(new Error(`Failed to parse response: ${data}`));
        }
      });
    });

    req.on('error', (e) => {
      reject(e);
    });

    req.write(postData);
    req.end();
  });
}

// Update post
async function updatePost(config, postId, updateData) {
  const url = `${config.baseUrl}/wp/v2/posts/${postId}`;
  const auth = `${config.user}:${config.password}`;

  console.log(`Updating post ID: ${postId}`);

  const payload = JSON.stringify(updateData);

  try {
    const result = await makeRequest(url, auth, 'PUT', payload);
    return result;
  } catch (error) {
    throw new Error(`Failed to update post: ${error.message}`);
  }
}

// Save result to file
function saveResult(result, outputFile) {
  const data = {
    id: result.id,
    title: result.title.rendered,
    link: result.link,
    status: result.status,
    featured_media: result.featured_media,
    date_modified: result.modified
  };

  fs.writeFileSync(outputFile, JSON.stringify(data, null, 2));
  console.log(`\nPost details saved to: ${outputFile}`);
}

// Main execution
async function main() {
  try {
    const options = parseArgs();
    const config = loadConfig();

    if (!options.id) {
      console.error('Error: --id is required');
      process.exit(1);
    }

    let updateData = {};

    // Load from file or use command line args
    if (options.file) {
      console.log(`Loading update data from: ${options.file}`);
      const fileContent = fs.readFileSync(options.file, 'utf8');
      updateData = JSON.parse(fileContent);
    } else {
      // Build update data from command line options
      if (options.title !== null) updateData.title = options.title;
      if (options.content !== null) updateData.content = options.content;
      if (options.excerpt !== null) updateData.excerpt = options.excerpt;
      if (options.status !== null) updateData.status = options.status;
      if (options.categories !== null) updateData.categories = options.categories;
      if (options.tags !== null) updateData.tags = options.tags;
      if (options.featured_media !== null) updateData.featured_media = options.featured_media;
      if (Object.keys(options.meta).length > 0) updateData.meta = options.meta;

      if (Object.keys(updateData).length === 0) {
        console.error('Error: No update fields provided');
        process.exit(1);
      }
    }

    // Update the post
    const result = await updatePost(config, options.id, updateData);

    console.log('\n✓ Post updated successfully!');
    console.log(`  ID: ${result.id}`);
    console.log(`  Title: ${result.title.rendered}`);
    console.log(`  Status: ${result.status}`);
    console.log(`  Link: ${result.link}`);
    if (result.featured_media) {
      console.log(`  Featured Media ID: ${result.featured_media}`);
    }

    // Save result
    const outputFile = options.output || 'updated-post.json';
    saveResult(result, outputFile);

  } catch (error) {
    console.error('\n✗ Error:', error.message);
    process.exit(1);
  }
}

// Run
main();
