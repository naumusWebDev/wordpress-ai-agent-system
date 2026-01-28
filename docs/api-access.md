# WordPress REST API Access Configuration

This document explains how to access the WordPress REST API for automation and scripting purposes.

---

## Authentication Method: Application Passwords

**Application Passwords** is the recommended authentication method for this project.

### What are Application Passwords?

- Built-in WordPress feature (since WordPress 5.6)
- No plugins required
- Secure alternative to using actual account passwords
- Easily revocable without affecting the main account password
- Designed specifically for API and automation access

---

## Setup Instructions

### Prerequisites

1. WordPress 5.6 or later (✓ installed)
2. HTTPS enabled on the site **OR** running on `localhost` (✓ local development)
3. Docker environment running: `docker compose up -d`
4. WordPress installation completed via browser or WP-CLI

---

## Step 1: Complete WordPress Installation

Before generating Application Passwords, WordPress must be installed and configured.

### Option A: Browser Installation (Recommended for first-time setup)

1. Add `organicstore.local` to your hosts file:
   - **Windows**: `C:\Windows\System32\drivers\etc\hosts`
   - **Linux/Mac**: `/etc/hosts`

   Add this line:
   ```
   127.0.0.1 organicstore.local
   ```

2. Start Docker containers:
   ```bash
   docker compose up -d
   ```

3. Visit `http://organicstore.local` in your browser

4. Complete the installation wizard:
   - **Site Title**: Organic Store
   - **Username**: admin (or your preferred admin username)
   - **Password**: (use a strong password)
   - **Email**: admin@organicstore.local

### Option B: WP-CLI Installation (Automated)

```bash
# Install WordPress via WP-CLI
docker compose run --rm wpcli core install \
  --url="http://organicstore.local" \
  --title="Organic Store" \
  --admin_user="admin" \
  --admin_password="your_secure_password" \
  --admin_email="admin@organicstore.local"

# Activate the child theme
docker compose run --rm wpcli theme activate organics-child
```

---

## Step 2: Create Application Password

### Option A: Via WordPress Admin Dashboard

1. Log in to WordPress admin: `http://organicstore.local/wp-admin`

2. Navigate to: **Users → Profile** (or **Users → Your Profile**)

3. Scroll to **Application Passwords** section

4. Create a new Application Password:
   - **Application Name**: `REST API Scripts` (or any descriptive name)
   - Click **Add New Application Password**

5. **IMPORTANT**: Copy the generated password immediately
   - Format: `xxxx xxxx xxxx xxxx xxxx xxxx` (24 characters with spaces)
   - This password is shown **only once**
   - Store it securely in your `.env` file

### Option B: Via WP-CLI (Recommended for automation)

```bash
# Create a dedicated API user (optional but recommended)
docker compose run --rm wpcli user create api_user api@organicstore.local \
  --role=administrator \
  --display_name="API User"

# Generate an Application Password for the user
docker compose run --rm wpcli user application-password create admin "REST API Scripts"

# OR for the dedicated API user:
docker compose run --rm wpcli user application-password create api_user "REST API Scripts"
```

**Output example:**
```
Success: Created application password.
Password: xxxx xxxx xxxx xxxx xxxx xxxx
```

**Copy this password immediately!**

---

## Step 3: Store Credentials Securely

### Create `.env` file

Copy the `.env.example` file:

```bash
cp .env.example .env
```

### Add API Credentials to `.env`

Open `.env` and update the following:

```bash
# WordPress REST API Authentication
# Format: username:application_password (remove spaces from the password)
WP_API_AUTH=admin:xxxxxxxxxxxxxxxxxxxxxxxx
WP_API_BASE_URL=http://organicstore.local/wp-json
```

**IMPORTANT**:
- Remove all spaces from the Application Password
- Never commit `.env` to version control (already in `.gitignore`)
- Format is `username:password` (no spaces around the colon)

---

## Step 4: Test API Access

### Using curl

```bash
# Test authentication
curl -i \
  --user "admin:xxxxxxxxxxxxxxxxxxxx" \
  http://organicstore.local/wp-json/wp/v2/users/me

# Expected response: HTTP 200 with user data
```

### Using Node.js (example for scripts)

```javascript
const axios = require('axios');

const apiClient = axios.create({
  baseURL: process.env.WP_API_BASE_URL || 'http://organicstore.local/wp-json',
  auth: {
    username: process.env.WP_API_AUTH.split(':')[0],
    password: process.env.WP_API_AUTH.split(':')[1]
  }
});

// Test request
async function testConnection() {
  try {
    const response = await apiClient.get('/wp/v2/users/me');
    console.log('Connected successfully:', response.data);
  } catch (error) {
    console.error('Connection failed:', error.message);
  }
}

testConnection();
```

---

## Available REST API Endpoints

WordPress REST API provides endpoints for managing:

- **Posts**: `/wp/v2/posts`
- **Pages**: `/wp/v2/pages`
- **Media**: `/wp/v2/media`
- **Users**: `/wp/v2/users`
- **Categories**: `/wp/v2/categories`
- **Tags**: `/wp/v2/tags`
- **Comments**: `/wp/v2/comments`
- **Settings**: `/wp/v2/settings`
- **Custom Post Types**: `/wp/v2/{post_type}`

### API Documentation

- Browse available endpoints: `http://organicstore.local/wp-json`
- WordPress REST API Handbook: https://developer.wordpress.org/rest-api/

---

## Security Best Practices

1. **Never commit credentials**
   - Always use `.env` for secrets
   - `.env` is git-ignored by default

2. **Use dedicated API users**
   - Create a separate user account for API access
   - Assign minimum required permissions (Editor vs Administrator)

3. **Revoke unused passwords**
   - Regularly review and revoke Application Passwords
   - Each script/integration should have its own Application Password

4. **Rotate credentials**
   - Change Application Passwords periodically
   - Immediately revoke if compromised

5. **Local development only**
   - Current setup is for local development
   - Production environments MUST use HTTPS

---

## Managing Application Passwords

### List all Application Passwords for a user

```bash
docker compose run --rm wpcli user application-password list admin
```

### Revoke an Application Password

Via WP-CLI:
```bash
docker compose run --rm wpcli user application-password delete admin <UUID>
```

Via WordPress Admin:
- Go to **Users → Profile**
- Click **Revoke** next to the Application Password

---

## Troubleshooting

### "Application Passwords are not available"

**Cause**: HTTPS is not enabled or site is not running on localhost

**Solution**:
- Ensure `WP_SITEURL` and `WP_HOME` use `http://organicstore.local` (localhost domain)
- Check `wp-config.php` contains correct site URLs

### Authentication fails with 401 Unauthorized

**Possible causes**:
1. Incorrect username or password
2. Spaces not removed from Application Password
3. User doesn't have sufficient permissions

**Solution**:
- Verify credentials in `.env`
- Ensure Application Password has no spaces
- Check user role (must be at least Editor)

### REST API returns 404

**Possible causes**:
1. Permalinks not configured
2. `.htaccess` issues (if using Apache)

**Solution**:
```bash
# Flush rewrite rules
docker compose run --rm wpcli rewrite flush
```

---

## Next Steps

1. Complete WordPress installation (browser or WP-CLI)
2. Generate Application Password
3. Store credentials in `.env`
4. Test API connection
5. Start building automation scripts in `/scripts/wp-api/`

For script examples and conventions, see `/scripts/README.md` and `/scripts/catalog.md`.

---

**Document Status**: Generated by WordPress Initializer
**Last Updated**: 2026-01-11
**Maintained By**: Documenter agent
