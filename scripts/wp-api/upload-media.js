#!/usr/bin/env node

/**
 * WordPress REST API - Upload Media Script
 *
 * Uploads media files to WordPress Media Library via REST API
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
    file: null,
    url: null,
    title: '',
    alt_text: '',
    caption: '',
    description: '',
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
        case 'file':
          options.file = value || args[++i];
          break;
        case 'url':
          options.url = value || args[++i];
          break;
        case 'title':
          options.title = value || args[++i];
          break;
        case 'alt-text':
          options.alt_text = value || args[++i];
          break;
        case 'caption':
          options.caption = value || args[++i];
          break;
        case 'description':
          options.description = value || args[++i];
          break;
        case 'output':
          options.output = value || args[++i];
          break;
      }
    }
  }

  return options;
}

function printHelp() {
  console.log(`
WordPress REST API - Upload Media Script

Usage:
  node upload-media.js [options]

Options:
  --file=PATH                Local file path to upload
  --url=URL                  Remote URL to download and upload
  --title=TITLE              Media title
  --alt-text=TEXT            Alternative text for images
  --caption=TEXT             Media caption
  --description=TEXT         Media description
  --output=FILE              Save uploaded media info to JSON file (default: uploaded-media.json)
  -h, --help                 Show this help

Environment Variables:
  WP_API_BASE_URL            WordPress REST API base URL (required)
  WP_API_USER                WordPress username (required)
  WP_API_PASSWORD            Application Password (required)

Examples:
  # Upload local file
  node upload-media.js \\
    --file=/path/to/image.jpg \\
    --title="Product Image" \\
    --alt-text="Beautiful product"

  # Upload from URL
  node upload-media.js \\
    --url=https://example.com/image.jpg \\
    --title="Downloaded Image" \\
    --alt-text="Product photo"

  # Upload with full metadata
  node upload-media.js \\
    --file=cake.jpg \\
    --title="Tarta de la Abuela" \\
    --alt-text="Deliciosa tarta casera" \\
    --caption="Tarta tradicional" \\
    --description="Imagen de nuestra famosa tarta de la abuela"
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

// Download file from URL
function downloadFile(url) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const protocol = urlObj.protocol === 'https:' ? https : http;

    protocol.get(url, (res) => {
      if (res.statusCode === 302 || res.statusCode === 301) {
        // Follow redirect
        downloadFile(res.headers.location).then(resolve).catch(reject);
        return;
      }

      if (res.statusCode !== 200) {
        reject(new Error(`Failed to download: HTTP ${res.statusCode}`));
        return;
      }

      const chunks = [];
      res.on('data', (chunk) => chunks.push(chunk));
      res.on('end', () => resolve(Buffer.concat(chunks)));
      res.on('error', reject);
    }).on('error', reject);
  });
}

// Upload media to WordPress
function uploadMedia(config, fileBuffer, filename, metadata) {
  return new Promise((resolve, reject) => {
    const url = `${config.baseUrl}/wp/v2/media`;
    const urlObj = new URL(url);
    const protocol = urlObj.protocol === 'https:' ? https : http;

    const authHeader = 'Basic ' + Buffer.from(`${config.user}:${config.password}`).toString('base64');

    // Create multipart form data boundary
    const boundary = '----WebKitFormBoundary' + Math.random().toString(36).substring(2);

    // Build multipart body
    let body = '';

    // Add file
    body += `--${boundary}\r\n`;
    body += `Content-Disposition: form-data; name="file"; filename="${filename}"\r\n`;
    body += `Content-Type: ${getContentType(filename)}\r\n\r\n`;
    const bodyBuffer = Buffer.concat([
      Buffer.from(body, 'utf8'),
      fileBuffer,
      Buffer.from(`\r\n--${boundary}`, 'utf8')
    ]);

    // Add metadata fields
    let metaBody = '';
    if (metadata.title) {
      metaBody += `\r\nContent-Disposition: form-data; name="title"\r\n\r\n${metadata.title}\r\n--${boundary}`;
    }
    if (metadata.alt_text) {
      metaBody += `\r\nContent-Disposition: form-data; name="alt_text"\r\n\r\n${metadata.alt_text}\r\n--${boundary}`;
    }
    if (metadata.caption) {
      metaBody += `\r\nContent-Disposition: form-data; name="caption"\r\n\r\n${metadata.caption}\r\n--${boundary}`;
    }
    if (metadata.description) {
      metaBody += `\r\nContent-Disposition: form-data; name="description"\r\n\r\n${metadata.description}\r\n--${boundary}`;
    }

    metaBody += '--\r\n';

    const finalBody = Buffer.concat([bodyBuffer, Buffer.from(metaBody, 'utf8')]);

    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port || (urlObj.protocol === 'https:' ? 443 : 80),
      path: urlObj.pathname,
      method: 'POST',
      headers: {
        'Content-Type': `multipart/form-data; boundary=${boundary}`,
        'Authorization': authHeader,
        'Content-Length': finalBody.length
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

    req.write(finalBody);
    req.end();
  });
}

// Get content type from filename
function getContentType(filename) {
  const ext = path.extname(filename).toLowerCase();
  const types = {
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.png': 'image/png',
    '.gif': 'image/gif',
    '.webp': 'image/webp',
    '.svg': 'image/svg+xml',
    '.pdf': 'application/pdf',
    '.mp4': 'video/mp4',
    '.mp3': 'audio/mpeg'
  };
  return types[ext] || 'application/octet-stream';
}

// Save result to file
function saveResult(result, outputFile) {
  const data = {
    id: result.id,
    title: result.title.rendered,
    source_url: result.source_url,
    media_type: result.media_type,
    mime_type: result.mime_type,
    alt_text: result.alt_text,
    date: result.date
  };

  fs.writeFileSync(outputFile, JSON.stringify(data, null, 2));
  console.log(`\nMedia details saved to: ${outputFile}`);
}

// Main execution
async function main() {
  try {
    const options = parseArgs();
    const config = loadConfig();

    let fileBuffer;
    let filename;

    if (options.url) {
      // Download from URL
      console.log(`Downloading from: ${options.url}`);
      fileBuffer = await downloadFile(options.url);
      filename = path.basename(new URL(options.url).pathname);
      console.log(`Downloaded: ${filename} (${fileBuffer.length} bytes)`);
    } else if (options.file) {
      // Read local file
      console.log(`Reading local file: ${options.file}`);
      fileBuffer = fs.readFileSync(options.file);
      filename = path.basename(options.file);
      console.log(`Loaded: ${filename} (${fileBuffer.length} bytes)`);
    } else {
      console.error('Error: Either --file or --url is required');
      process.exit(1);
    }

    // Prepare metadata
    const metadata = {
      title: options.title || filename,
      alt_text: options.alt_text,
      caption: options.caption,
      description: options.description
    };

    // Upload to WordPress
    console.log(`Uploading to WordPress...`);
    const result = await uploadMedia(config, fileBuffer, filename, metadata);

    console.log('\n✓ Media uploaded successfully!');
    console.log(`  ID: ${result.id}`);
    console.log(`  Title: ${result.title.rendered}`);
    console.log(`  Type: ${result.media_type}`);
    console.log(`  URL: ${result.source_url}`);

    // Save result
    const outputFile = options.output || 'uploaded-media.json';
    saveResult(result, outputFile);

  } catch (error) {
    console.error('\n✗ Error:', error.message);
    process.exit(1);
  }
}

// Run
main();
