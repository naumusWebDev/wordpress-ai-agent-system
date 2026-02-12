# WordPress REST API Scripts

This directory contains automation scripts for operating WordPress via the REST API.

---

## Overview

Scripts in this directory enable:
- Batch operations (bulk create, update, delete)
- Data import/export
- Automation workflows
- Integration with external systems
- WP-CLI wrappers

---

## Directory Structure

```
scripts/
├── wp-api/              # REST API automation scripts
│   └── (scripts created by Scripter agent)
├── catalog.md           # Script registry (AUTHORITATIVE)
└── README.md            # This file
```

---

## Script Conventions

### Language

**Preferred**: Node.js (JavaScript)
- Async/await support
- Good HTTP libraries (axios, node-fetch)
- Consistent with WordPress ecosystem

**Alternative**: Python
- For data processing tasks
- When specific Python libraries needed

**Last Resort**: Bash
- Simple WP-CLI wrappers
- One-line operations

### Naming

```
[action]-[entity].js

Examples:
- create-bulk-posts.js
- delete-old-posts.js
- export-products.js
- import-users.csv
```

### Environment Variables

**NEVER** hardcode credentials. Always use `.env`:

```bash
# Required in .env
WP_API_BASE_URL=http://myproject.local/wp-json
WP_API_AUTH=username:application_password
```

---

## Running Scripts

### Node.js Scripts

```bash
# Ensure dependencies are installed
npm install

# Run script
node scripts/wp-api/script-name.js [arguments]

# Example
node scripts/wp-api/create-bulk-posts.js --file=posts.csv
```

### Python Scripts

```bash
# Install dependencies (if requirements.txt exists)
pip install -r requirements.txt

# Run script
python scripts/wp-api/script-name.py [arguments]
```

### Bash Scripts

```bash
# Make executable
chmod +x scripts/wp-api/script-name.sh

# Run
./scripts/wp-api/script-name.sh [arguments]
```

---

## Script Template (Node.js)

```javascript
#!/usr/bin/env node

/**
 * Script Name: [Descriptive Name]
 * Description: [What this script does]
 * Version: 1.0.0
 * Author: Scripter Agent
 *
 * Usage:
 *   node scripts/wp-api/script-name.js [args]
 *
 * Required Environment Variables:
 *   WP_API_BASE_URL - WordPress REST API base URL
 *   WP_API_AUTH - username:application_password
 *
 * Prerequisites:
 *   - Node.js 18+
 *   - npm install (axios, dotenv)
 *   - Application Password configured
 */

require('dotenv').config();
const axios = require('axios');

// Configuration
const config = {
  baseURL: process.env.WP_API_BASE_URL,
  auth: {
    username: process.env.WP_API_AUTH.split(':')[0],
    password: process.env.WP_API_AUTH.split(':')[1]
  }
};

// Validate environment
if (!config.baseURL || !config.auth.username || !config.auth.password) {
  console.error('Error: Missing required environment variables');
  console.error('Required: WP_API_BASE_URL, WP_API_AUTH');
  process.exit(1);
}

// Create API client
const api = axios.create(config);

// Main function
async function main() {
  try {
    // Your script logic here
    console.log('Script started...');

    // Example: Fetch posts
    const response = await api.get('/wp/v2/posts');
    console.log(`Found ${response.data.length} posts`);

    console.log('✅ Script completed successfully');

  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
    process.exit(1);
  }
}

// Run
main();
```

---

## Common Patterns

### Authentication

```javascript
// Basic Auth with Application Password
const api = axios.create({
  baseURL: 'http://myproject.local/wp-json',
  auth: {
    username: 'admin',
    password: 'xxxx xxxx xxxx xxxx xxxx xxxx'  // Application Password
  }
});
```

### Pagination

```javascript
async function getAllPosts() {
  let page = 1;
  let allPosts = [];
  let hasMore = true;

  while (hasMore) {
    const response = await api.get('/wp/v2/posts', {
      params: { per_page: 100, page }
    });

    allPosts = allPosts.concat(response.data);

    const totalPages = parseInt(response.headers['x-wp-totalpages']);
    hasMore = page < totalPages;
    page++;
  }

  return allPosts;
}
```

### Rate Limiting

```javascript
// Delay between requests to avoid overwhelming server
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

for (const item of items) {
  await processItem(item);
  await sleep(200); // 200ms delay
}
```

### Error Handling

```javascript
try {
  const response = await api.post('/wp/v2/posts', postData);
  console.log('✅ Created:', response.data.id);
} catch (error) {
  if (error.response) {
    // Server responded with error status
    console.error(`HTTP ${error.response.status}:`, error.response.data);
  } else if (error.request) {
    // No response received
    console.error('No response from server. Is WordPress running?');
  } else {
    // Other errors
    console.error('Error:', error.message);
  }
}
```

### Rollback Data

```javascript
// Save IDs for potential rollback
const createdIds = [];

for (const item of items) {
  const response = await api.post('/wp/v2/posts', item);
  createdIds.push(response.data.id);
}

// Save rollback data
fs.writeFileSync(
  'rollback.json',
  JSON.stringify({ ids: createdIds }, null, 2)
);
```

---

## Available REST API Endpoints

### WordPress Core Endpoints

```bash
GET    /wp/v2/posts           # List posts
POST   /wp/v2/posts           # Create post
GET    /wp/v2/posts/{id}      # Get specific post
PUT    /wp/v2/posts/{id}      # Update post
DELETE /wp/v2/posts/{id}      # Delete post

GET    /wp/v2/pages           # List pages
POST   /wp/v2/pages           # Create page

GET    /wp/v2/media           # List media
POST   /wp/v2/media           # Upload media

GET    /wp/v2/users           # List users
POST   /wp/v2/users           # Create user
GET    /wp/v2/users/me        # Current user (auth check)

GET    /wp/v2/categories      # List categories
POST   /wp/v2/categories      # Create category

GET    /wp/v2/tags            # List tags
POST   /wp/v2/tags            # Create tag

GET    /wp/v2/comments        # List comments

GET    /wp/v2/settings        # Site settings (read)
POST   /wp/v2/settings        # Update settings
```

### Custom Endpoints

Custom endpoints will be documented here as they are created by the Backend Engineer.

---

## Script Catalog

**IMPORTANT**: The **authoritative script registry** is maintained in:

📋 **`/scripts/catalog.md`**

The catalog is **owned exclusively by the Scripter agent**.

Before creating a new script:
1. Check the catalog for existing scripts
2. Reuse or extend if possible
3. Register new scripts in the catalog

---

## Dependencies

### Node.js Scripts

Common dependencies:

```bash
npm install axios dotenv csv-parser fs
```

### Python Scripts

Common dependencies:

```bash
pip install requests python-dotenv pandas
```

---

## Security Best Practices

1. **Never commit credentials**
   - Always use `.env` for secrets
   - `.env` is git-ignored

2. **Never log sensitive data**
   - Don't log passwords or API keys
   - Sanitize logs before outputting

3. **Validate inputs**
   - Check file existence before processing
   - Validate data before sending to API

4. **Use HTTPS in production**
   - Local development: `http://myproject.local` is OK
   - Production: **MUST** use `https://`

5. **Handle errors gracefully**
   - Don't expose internal errors to users
   - Log errors for debugging

---

## Testing Scripts

### Test with Sample Data

**Never test scripts on production data first!**

```bash
# Use test environment
export WP_API_BASE_URL=http://test.myproject.local/wp-json

# Use small sample data
node script.js --file=sample-data-small.csv
```

### Verify Rollback

```bash
# 1. Run script (creates rollback.json)
node create-posts.js --file=test.csv

# 2. Verify in WordPress
# (check created posts)

# 3. Test rollback
node delete-posts.js --file=rollback.json

# 4. Verify cleanup
# (posts should be deleted)
```

---

## Troubleshooting

### Error: "Missing required environment variables"

**Cause**: `.env` file not found or incomplete

**Solution**:
```bash
# Create .env from template
cp .env.example .env

# Edit .env and add:
WP_API_BASE_URL=http://myproject.local/wp-json
WP_API_AUTH=admin:your_app_password_here
```

### Error: HTTP 401 Unauthorized

**Cause**: Invalid credentials or Application Password not set up

**Solution**:
1. Verify Application Password exists (WordPress Admin → Users → Profile)
2. Check username and password in `.env`
3. Remove spaces from Application Password in `.env`

### Error: ECONNREFUSED

**Cause**: WordPress not running or wrong URL

**Solution**:
1. Check Docker is running: `docker compose ps`
2. Start WordPress: `docker compose up -d`
3. Verify URL in `.env` matches site URL

### Script runs but no changes in WordPress

**Cause**: Data validation failed or wrong endpoint

**Solution**:
1. Check script output for errors
2. Verify endpoint in script code
3. Check WordPress debug.log: `wp-content/debug.log`
4. Test endpoint manually with curl

---

## Getting Help

1. **Check catalog**: `/scripts/catalog.md` for similar scripts
2. **Read docs**: `/docs/api-access.md` for API setup
3. **Invoke Scripter**: `/project:create-wp-api-script` for new scripts
4. **WordPress API Docs**: https://developer.wordpress.org/rest-api/

---

**Last Updated**: 2026-01-11
**Maintained By**: Scripter Agent
