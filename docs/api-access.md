# WordPress REST API Access Configuration

How to authenticate and use the WordPress REST API for automation scripts.

---

## Authentication Method: Application Passwords

**Application Passwords** is the recommended method. It is a built-in WordPress feature (since 5.6) that requires no plugins.

- Easily revocable without affecting the main account password
- Designed specifically for API and automation access
- Works on `localhost` without HTTPS

---

## Prerequisites

- WordPress 5.6 or later
- Admin access to the WordPress dashboard
- Environment running (Docker containers **or** Local WP site)

---

## Generate an Application Password

### Via WordPress Admin Dashboard

1. Log in to WordPress admin: `http://myproject.local/wp-admin`
2. Navigate to **Users → Profile**
3. Scroll to the **Application Passwords** section
4. Enter a name (e.g. `REST API Scripts`) and click **Add New Application Password**
5. **Copy the generated password immediately** — it is shown only once
   - Format: `xxxx xxxx xxxx xxxx xxxx xxxx`

### Via WP-CLI

**Docker mode:**
```bash
docker compose run --rm wpcli user application-password create admin "REST API Scripts"
```

**Local WP mode (WSL):**
```bash
wp --path="/path/to/wordpress" user application-password create admin "REST API Scripts"
```

Output:
```
Success: Created application password.
Password: xxxx xxxx xxxx xxxx xxxx xxxx
```

---

## Store Credentials in `.env`

Copy the template and fill in your values:

```bash
cp .env.example .env
```

Add the API credentials:

```bash
# WordPress REST API Authentication
WP_API_BASE_URL=http://myproject.local/wp-json
WP_API_USER=admin
WP_API_PASSWORD=xxxxxxxxxxxxxxxxxxxxxxxx
```

> **Important**: Remove all spaces from the Application Password before storing it.

> **Never commit `.env`** — it is already in `.gitignore`.

---

## Test API Access

### Using curl

```bash
# Docker mode
curl -s --user "admin:xxxxxxxxxxxxxxxxxxxxxxxx" \
  http://myproject.local/wp-json/wp/v2/users/me | head -c 200

# Local WP mode (use the site's URL)
curl -s --user "admin:xxxxxxxxxxxxxxxxxxxxxxxx" \
  http://myproject.local/wp-json/wp/v2/users/me | head -c 200
```

A successful response returns HTTP 200 with JSON user data.

### Common errors

| Symptom | Cause | Fix |
|---------|-------|-----|
| `401 Unauthorized` | Wrong credentials | Regenerate Application Password |
| `403 Forbidden` | User lacks permissions | Use an administrator account |
| `404 Not Found` | Wrong base URL | Check `WP_API_BASE_URL` and permalink settings |
| Connection refused | Site not running | Start Docker containers or Local WP site |

---

## Using with REST API Scripts

The scripts in `scripts/wp-api/` read credentials from environment variables:

```bash
# Load .env and run a script
export $(grep -v '^#' .env | xargs)
node scripts/wp-api/create-post.js --title="Test Post" --status=draft
```

Or source the `.env` inline:

```bash
source .env
node scripts/wp-api/create-post.js --file=post-data.json
```

### Available scripts

| Script | Purpose |
|--------|---------|
| `create-post.js` | Create posts via REST API |
| `update-post.js` | Update existing posts |
| `upload-media.js` | Upload media files |
| `create-product.js` | Create WooCommerce products |
| `update-product.js` | Update WooCommerce products |

See [scripts/catalog.md](../scripts/catalog.md) for full documentation.

---

## Security Best Practices

1. **Use Application Passwords** — never your main WordPress password
2. **One password per integration** — revoke individually if compromised
3. **Store in `.env` only** — never hardcode in scripts or commit to git
4. **Minimum privileges** — create a dedicated API user with only the required role
5. **Revoke unused passwords** in **Users → Profile → Application Passwords**

---

## Available REST API Endpoints

Common WordPress REST API endpoints:

| Endpoint | Resource |
|----------|----------|
| `/wp/v2/posts` | Posts |
| `/wp/v2/pages` | Pages |
| `/wp/v2/media` | Media |
| `/wp/v2/users` | Users |
| `/wp/v2/categories` | Categories |
| `/wp/v2/tags` | Tags |
| `/wc/v3/products` | WooCommerce Products |

Full reference: [REST API Handbook](https://developer.wordpress.org/rest-api/reference/)
