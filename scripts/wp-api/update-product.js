#!/usr/bin/env node

/**
 * WordPress REST API - Update WooCommerce Product Script
 *
 * Updates an existing product in WooCommerce via REST API
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
    name: null,
    description: null,
    short_description: null,
    regular_price: null,
    sale_price: null,
    sku: null,
    stock_status: null,
    categories: null,
    tags: null,
    images: null,
    featured_image: null,
    meta_data: [],
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
        case 'name':
          options.name = value || args[++i];
          break;
        case 'description':
          options.description = value || args[++i];
          break;
        case 'short-description':
          options.short_description = value || args[++i];
          break;
        case 'regular-price':
          options.regular_price = value || args[++i];
          break;
        case 'sale-price':
          options.sale_price = value || args[++i];
          break;
        case 'sku':
          options.sku = value || args[++i];
          break;
        case 'stock-status':
          options.stock_status = value || args[++i];
          break;
        case 'categories':
          options.categories = (value || args[++i]).split(',').map(c => parseInt(c.trim()));
          break;
        case 'tags':
          options.tags = (value || args[++i]).split(',').map(t => parseInt(t.trim()));
          break;
        case 'images':
          options.images = (value || args[++i]).split(',').map(id => ({ id: parseInt(id.trim()) }));
          break;
        case 'featured-image':
          options.featured_image = parseInt(value || args[++i]);
          break;
        case 'file':
          options.file = value || args[++i];
          break;
        case 'output':
          options.output = value || args[++i];
          break;
        default:
          // Handle meta_data fields
          if (key.startsWith('meta-')) {
            const metaKey = key.replace('meta-', '').replace(/-/g, '_');
            const metaValue = value || args[++i];

            let parsedValue = metaValue;
            try {
              parsedValue = JSON.parse(metaValue);
            } catch (e) {
              // Keep as string if not valid JSON
            }

            options.meta_data.push({
              key: metaKey,
              value: parsedValue
            });
          }
      }
    }
  }

  return options;
}

function printHelp() {
  console.log(`
WordPress REST API - Update WooCommerce Product Script

Usage:
  node update-product.js --id=ID [options]

Options:
  --id=ID                        Product ID (required)
  --name=NAME                    Product name
  --description=DESC             Full product description (HTML allowed)
  --short-description=DESC       Short description
  --regular-price=PRICE          Regular price
  --sale-price=PRICE             Sale price
  --sku=SKU                      Stock Keeping Unit
  --stock-status=STATUS          Stock status: instock, outofstock, onbackorder
  --categories=IDS               Comma-separated category IDs
  --tags=IDS                     Comma-separated tag IDs
  --images=IDS                   Comma-separated media IDs for product images
  --featured-image=ID            Media ID for featured image
  --meta-KEY=VALUE               Update custom meta field
  --file=FILE                    Read update data from JSON file
  --output=FILE                  Save updated product info to JSON file
  -h, --help                     Show this help

Environment Variables:
  WP_API_BASE_URL                WordPress REST API base URL (required)
  WP_API_USER                    WordPress username (required)
  WP_API_PASSWORD                Application Password (required)

Examples:
  # Update product name and price
  node update-product.js --id=3713 \\
    --name="Nueva Tarta de la Abuela" \\
    --regular-price=29.99

  # Add images to product
  node update-product.js --id=3713 \\
    --images=123,124,125 \\
    --featured-image=123

  # Update from JSON file
  node update-product.js --id=3713 --file=product-update.json

JSON File Format (--file option):
  {
    "name": "Updated Product Name",
    "regular_price": "39.99",
    "images": [
      { "id": 123 },
      { "id": 124 }
    ]
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

// Update product
async function updateProduct(config, productId, updateData) {
  const url = `${config.baseUrl}/wc/v3/products/${productId}`;
  const auth = `${config.user}:${config.password}`;

  console.log(`Updating product ID: ${productId}`);

  const payload = JSON.stringify(updateData);

  try {
    const result = await makeRequest(url, auth, 'PUT', payload);
    return result;
  } catch (error) {
    throw new Error(`Failed to update product: ${error.message}`);
  }
}

// Save result to file
function saveResult(result, outputFile) {
  const data = {
    id: result.id,
    name: result.name,
    permalink: result.permalink,
    type: result.type,
    price: result.price,
    regular_price: result.regular_price,
    sku: result.sku,
    stock_status: result.stock_status,
    images: result.images,
    date_modified: result.date_modified
  };

  fs.writeFileSync(outputFile, JSON.stringify(data, null, 2));
  console.log(`\nProduct details saved to: ${outputFile}`);
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
      if (options.name !== null) updateData.name = options.name;
      if (options.description !== null) updateData.description = options.description;
      if (options.short_description !== null) updateData.short_description = options.short_description;
      if (options.regular_price !== null) updateData.regular_price = options.regular_price;
      if (options.sale_price !== null) updateData.sale_price = options.sale_price;
      if (options.sku !== null) updateData.sku = options.sku;
      if (options.stock_status !== null) updateData.stock_status = options.stock_status;
      if (options.categories !== null) {
        updateData.categories = options.categories.map(id => ({ id }));
      }
      if (options.tags !== null) {
        updateData.tags = options.tags.map(id => ({ id }));
      }
      if (options.images !== null) {
        updateData.images = options.images;
      }
      if (options.featured_image !== null) {
        updateData.images = updateData.images || [];
        // Ensure featured image is first
        updateData.images = [{ id: options.featured_image }, ...updateData.images.filter(img => img.id !== options.featured_image)];
      }
      if (options.meta_data.length > 0) {
        updateData.meta_data = options.meta_data;
      }

      if (Object.keys(updateData).length === 0) {
        console.error('Error: No update fields provided');
        process.exit(1);
      }
    }

    // Update the product
    const result = await updateProduct(config, options.id, updateData);

    console.log('\n✓ Product updated successfully!');
    console.log(`  ID: ${result.id}`);
    console.log(`  Name: ${result.name}`);
    console.log(`  Price: ${result.price}`);
    console.log(`  Link: ${result.permalink}`);
    if (result.images && result.images.length > 0) {
      console.log(`  Images: ${result.images.length} image(s)`);
    }

    // Save result
    const outputFile = options.output || 'updated-product.json';
    saveResult(result, outputFile);

  } catch (error) {
    console.error('\n✗ Error:', error.message);
    process.exit(1);
  }
}

// Run
main();
