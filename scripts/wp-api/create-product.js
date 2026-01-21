#!/usr/bin/env node

/**
 * WordPress REST API - Create WooCommerce Product Script
 *
 * Creates a new product in WooCommerce via REST API
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
    name: '',
    description: '',
    short_description: '',
    type: 'simple',
    regular_price: '',
    sale_price: '',
    sku: '',
    stock_status: 'instock',
    manage_stock: false,
    stock_quantity: null,
    categories: [],
    tags: [],
    images: [],
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
        case 'name':
          options.name = value || args[++i];
          break;
        case 'description':
          options.description = value || args[++i];
          break;
        case 'short-description':
          options.short_description = value || args[++i];
          break;
        case 'type':
          options.type = value || args[++i];
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
        case 'manage-stock':
          options.manage_stock = true;
          break;
        case 'stock-quantity':
          options.stock_quantity = parseInt(value || args[++i]);
          break;
        case 'categories':
          options.categories = (value || args[++i]).split(',').map(c => parseInt(c.trim()));
          break;
        case 'tags':
          options.tags = (value || args[++i]).split(',').map(t => parseInt(t.trim()));
          break;
        case 'images':
          options.images = (value || args[++i]).split(',').map(img => ({ src: img.trim() }));
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

            // Try to parse as JSON for complex meta values
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
WordPress REST API - Create WooCommerce Product Script

Usage:
  node create-product.js [options]

Options:
  --name=NAME                    Product name (required)
  --description=DESC             Full product description (HTML allowed)
  --short-description=DESC       Short description
  --type=TYPE                    Product type: simple, variable, grouped, external (default: simple)
  --regular-price=PRICE          Regular price
  --sale-price=PRICE             Sale price (optional)
  --sku=SKU                      Stock Keeping Unit
  --stock-status=STATUS          Stock status: instock, outofstock, onbackorder (default: instock)
  --manage-stock                 Enable stock management
  --stock-quantity=QTY           Stock quantity (requires --manage-stock)
  --categories=IDS               Comma-separated category IDs
  --tags=IDS                     Comma-separated tag IDs
  --images=URLS                  Comma-separated image URLs
  --meta-KEY=VALUE               Custom meta field (e.g., --meta-custom_field=value)
                                 For complex values use JSON: --meta-cake_sizes='{"small":{"price":15}}'
  --file=FILE                    Read product data from JSON file
  --output=FILE                  Save created product info to JSON file (default: created-product.json)
  -h, --help                     Show this help

Environment Variables:
  WP_API_BASE_URL                WordPress REST API base URL (required)
  WP_API_USER                    WordPress username (required)
  WP_API_PASSWORD                Application Password (required)

Examples:
  # Create a simple product
  node create-product.js \\
    --name="Premium T-Shirt" \\
    --description="<p>High quality cotton t-shirt</p>" \\
    --regular-price=29.99 \\
    --sku=TSHIRT-001

  # Create product with categories and images
  node create-product.js \\
    --name="Blue Jeans" \\
    --regular-price=59.99 \\
    --categories=15,16 \\
    --images="https://example.com/image1.jpg,https://example.com/image2.jpg"

  # Create from JSON file
  node create-product.js --file=product-data.json

  # Create cake product with meta data
  node create-product.js \\
    --name="Chocolate Cake" \\
    --regular-price=25.00 \\
    --meta-is_cake_product=yes \\
    --meta-cake_sizes='{"small":{"servings":6,"price":15},"medium":{"servings":12,"price":25},"large":{"servings":24,"price":45}}'

JSON File Format (--file option):
  {
    "name": "Product Name",
    "description": "<p>Product description</p>",
    "short_description": "Brief description",
    "type": "simple",
    "regular_price": "29.99",
    "sku": "PROD-001",
    "categories": [15, 16],
    "images": [
      { "src": "https://example.com/image.jpg" }
    ],
    "meta_data": [
      { "key": "_is_cake_product", "value": "yes" },
      { "key": "_cake_sizes", "value": {...} }
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
    console.error('Example: export WP_API_BASE_URL=http://organicstore.local/wp-json');
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

// Create product
async function createProduct(config, productData) {
  const url = `${config.baseUrl}/wc/v3/products`;
  const auth = `${config.user}:${config.password}`;

  console.log(`Creating product: "${productData.name}"`);
  console.log(`Type: ${productData.type}`);
  if (productData.regular_price) {
    console.log(`Price: ${productData.regular_price}`);
  }

  const payload = JSON.stringify(productData);

  try {
    const result = await makeRequest(url, auth, payload);
    return result;
  } catch (error) {
    throw new Error(`Failed to create product: ${error.message}`);
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
    date_created: result.date_created,
    categories: result.categories,
    tags: result.tags
  };

  fs.writeFileSync(outputFile, JSON.stringify(data, null, 2));
  console.log(`\nProduct details saved to: ${outputFile}`);
}

// Main execution
async function main() {
  try {
    const options = parseArgs();
    const config = loadConfig();

    let productData;

    // Load from file or use command line args
    if (options.file) {
      console.log(`Loading product data from: ${options.file}`);
      const fileContent = fs.readFileSync(options.file, 'utf8');
      productData = JSON.parse(fileContent);
    } else {
      if (!options.name) {
        console.error('Error: --name is required when not using --file');
        process.exit(1);
      }

      productData = {
        name: options.name,
        type: options.type,
        status: 'publish'
      };

      if (options.description) productData.description = options.description;
      if (options.short_description) productData.short_description = options.short_description;
      if (options.regular_price) productData.regular_price = options.regular_price;
      if (options.sale_price) productData.sale_price = options.sale_price;
      if (options.sku) productData.sku = options.sku;
      if (options.stock_status) productData.stock_status = options.stock_status;
      if (options.manage_stock) {
        productData.manage_stock = true;
        if (options.stock_quantity !== null) {
          productData.stock_quantity = options.stock_quantity;
        }
      }
      if (options.categories.length > 0) {
        productData.categories = options.categories.map(id => ({ id }));
      }
      if (options.tags.length > 0) {
        productData.tags = options.tags.map(id => ({ id }));
      }
      if (options.images.length > 0) {
        productData.images = options.images;
      }
      if (options.meta_data.length > 0) {
        productData.meta_data = options.meta_data;
      }
    }

    // Create the product
    const result = await createProduct(config, productData);

    console.log('\n✓ Product created successfully!');
    console.log(`  ID: ${result.id}`);
    console.log(`  Name: ${result.name}`);
    console.log(`  Type: ${result.type}`);
    console.log(`  Price: ${result.price}`);
    console.log(`  Link: ${result.permalink}`);

    // Save result
    const outputFile = options.output || 'created-product.json';
    saveResult(result, outputFile);

    console.log('\nNote: To delete this product, use WooCommerce admin or REST API DELETE request');

  } catch (error) {
    console.error('\n✗ Error:', error.message);
    process.exit(1);
  }
}

// Run
main();
