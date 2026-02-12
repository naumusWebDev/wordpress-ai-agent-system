#!/usr/bin/env node

/**
 * WordPress REST API - Create Post Script
 *
 * Creates a new post in WordPress via REST API
 *
 * @version 1.0.0
 * @author Scripter Agent
 */

const https = require('https');
const http = require('http');
const fs = require('fs');
const path = require('path');

// Parse command line arguments
function parseArgs() {
  const args = process.argv.slice(2);
  const options = {
    title: '',
    content: '',
    status: 'draft',
    categories: [],
    tags: [],
    excerpt: '',
    featured_media: null,
    format: 'standard',
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
        case 'title':
          options.title = value || args[++i];
          break;
        case 'content':
          options.content = value || args[++i];
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
        case 'excerpt':
          options.excerpt = value || args[++i];
          break;
        case 'featured-media':
          options.featured_media = parseInt(value || args[++i]);
          break;
        case 'format':
          options.format = value || args[++i];
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
WordPress REST API - Create Post Script

Usage:
  node create-post.js [options]

Options:
  --title=TITLE              Post title (required)
  --content=CONTENT          Post content in HTML
  --status=STATUS            Post status: draft, publish, pending, private (default: draft)
  --categories=IDS           Comma-separated category IDs (e.g., "1,3,5")
  --tags=IDS                 Comma-separated tag IDs
  --excerpt=TEXT             Post excerpt
  --featured-media=ID        Featured image media ID
  --format=FORMAT            Post format: standard, aside, gallery, link, image, quote, status, video, audio, chat
  --meta-KEY=VALUE           Custom meta field (e.g., --meta-custom_field=value)
  --file=FILE                Read post data from JSON file
  --output=FILE              Save created post info to JSON file (default: created-post.json)
  -h, --help                 Show this help

Environment Variables:
  WP_API_BASE_URL            WordPress REST API base URL (required)
  WP_API_USER                WordPress username (required)
  WP_API_PASSWORD            Application Password or regular password (required)

Examples:
  # Create a simple draft post
  node create-post.js --title="My Post" --content="<p>Hello World</p>"

  # Create and publish a post with categories
  node create-post.js --title="News" --content="<p>Content</p>" --status=publish --categories=1,3

  # Create from JSON file
  node create-post.js --file=post-data.json

  # Create with custom meta
  node create-post.js --title="Product" --content="<p>Description</p>" --meta-price=29.99

JSON File Format (--file option):
  {
    "title": "Post Title",
    "content": "<p>Post content in HTML</p>",
    "status": "publish",
    "categories": [1, 3],
    "tags": [5, 7],
    "excerpt": "Post excerpt",
    "meta": {
      "custom_field": "value"
    }
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
    console.error('Example: export WP_API_BASE_URL=http://myproject.local/wp-json');
    process.exit(1);
  }

  if (!config.user || !config.password) {
    console.error('Error: WP_API_USER and WP_API_PASSWORD environment variables are required');
    console.error('Example: export WP_API_USER=admin');
    console.error('         export WP_API_PASSWORD=your_application_password');
    process.exit(1);
  }

  return config;
}

// Make HTTP request
function makeRequest(url, auth, postData) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const protocol = urlObj.protocol === 'https:' ? https : http;

    const authHeader = 'Basic ' + Buffer.from(auth).toString('base64');

    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port || (urlObj.protocol === 'https:' ? 443 : 80),
      path: urlObj.pathname,
      method: 'POST',
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

// Create post
async function createPost(config, postData) {
  const url = `${config.baseUrl}/wp/v2/posts`;
  const auth = `${config.user}:${config.password}`;

  console.log(`Creating post: "${postData.title}"`);
  console.log(`Status: ${postData.status}`);

  const payload = JSON.stringify(postData);

  try {
    const result = await makeRequest(url, auth, payload);
    return result;
  } catch (error) {
    throw new Error(`Failed to create post: ${error.message}`);
  }
}

// Save result to file
function saveResult(result, outputFile) {
  const data = {
    id: result.id,
    title: result.title.rendered,
    link: result.link,
    status: result.status,
    date: result.date,
    modified: result.modified,
    author: result.author,
    categories: result.categories,
    tags: result.tags
  };

  fs.writeFileSync(outputFile, JSON.stringify(data, null, 2));
  console.log(`\nPost details saved to: ${outputFile}`);
}

// Main execution
async function main() {
  try {
    const options = parseArgs();
    const config = loadConfig();

    let postData;

    // Load from file or use command line args
    if (options.file) {
      console.log(`Loading post data from: ${options.file}`);
      const fileContent = fs.readFileSync(options.file, 'utf8');
      postData = JSON.parse(fileContent);
    } else {
      if (!options.title) {
        console.error('Error: --title is required when not using --file');
        process.exit(1);
      }

      postData = {
        title: options.title,
        content: options.content,
        status: options.status
      };

      if (options.categories.length > 0) postData.categories = options.categories;
      if (options.tags.length > 0) postData.tags = options.tags;
      if (options.excerpt) postData.excerpt = options.excerpt;
      if (options.featured_media) postData.featured_media = options.featured_media;
      if (options.format) postData.format = options.format;
      if (Object.keys(options.meta).length > 0) postData.meta = options.meta;
    }

    // Create the post
    const result = await createPost(config, postData);

    console.log('\n✓ Post created successfully!');
    console.log(`  ID: ${result.id}`);
    console.log(`  Title: ${result.title.rendered}`);
    console.log(`  Status: ${result.status}`);
    console.log(`  Link: ${result.link}`);

    // Save result
    const outputFile = options.output || 'created-post.json';
    saveResult(result, outputFile);

    console.log('\nRollback command:');
    console.log(`  node delete-post.js --id=${result.id}`);

  } catch (error) {
    console.error('\n✗ Error:', error.message);
    process.exit(1);
  }
}

// Run
main();
