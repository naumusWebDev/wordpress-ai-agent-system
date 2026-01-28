# Development Environment Setup

This document explains how to set up and run the WordPress development environment.

---

## Overview

This project uses **Docker** for a reproducible development environment with:
- **WordPress** (latest) with PHP 8.3
- **MySQL** 8.0
- **WP-CLI** (WordPress command-line interface)

---

## Prerequisites

### Required
- **Docker Desktop** (Windows/Mac) or **Docker Engine** (Linux)
- **Docker Compose** v2.0+
- **Git** (for version control)

### Optional but Recommended
- **Node.js** 18+ (for running REST API scripts)
- **Code Editor** (VS Code, PhpStorm, etc.)

---

## Quick Start

### 1. Add Domain to Hosts File

**Windows**: Edit `C:\Windows\System32\drivers\etc\hosts` (as Administrator)
**Linux/Mac**: Edit `/etc/hosts` (with sudo)

Add this line:
```
127.0.0.1 organicstore.local
```

### 2. Create Environment File

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` and update values if needed:

```bash
# Database
DB_NAME=organicstore
DB_USER=wordpress
DB_PASSWORD=your_secure_password_here
DB_ROOT_PASSWORD=your_root_password_here

# Site URLs
WP_HOME=http://organicstore.local
WP_SITEURL=http://organicstore.local

# Admin User (for initial setup)
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=your_admin_password_here
WP_ADMIN_EMAIL=admin@organicstore.local
```

**⚠️ Important**: Never commit the `.env` file. It's already in `.gitignore`.

### 3. Start Docker Containers

```bash
docker compose up -d
```

This will:
- Download Docker images (first time only)
- Start MySQL database
- Start WordPress with PHP 8.3
- Start WP-CLI container

### 4. Install WordPress

**Option A: Browser Installation**

1. Visit `http://organicstore.local` in your browser
2. Complete the WordPress installation wizard:
   - **Site Title**: Organic Store
   - **Username**: admin (or your choice)
   - **Password**: (strong password)
   - **Email**: your_email@example.com
3. Log in to WordPress admin

**Option B: WP-CLI Installation (Automated)**

```bash
docker compose run --rm wpcli core install \
  --url="http://organicstore.local" \
  --title="Organic Store" \
  --admin_user="admin" \
  --admin_password="your_password" \
  --admin_email="admin@organicstore.local"
```

### 5. Activate Child Theme

```bash
docker compose run --rm wpcli theme activate organics-child
```

### 6. Verify Installation

Visit these URLs:
- **Frontend**: http://organicstore.local
- **Admin**: http://organicstore.local/wp-admin

---

## Docker Container Commands

### Start Containers
```bash
docker compose up -d
```

### Stop Containers
```bash
docker compose down
```

### View Logs
```bash
# All containers
docker compose logs -f

# Specific container
docker compose logs -f wordpress
```

### Restart Containers
```bash
docker compose restart
```

### Check Container Status
```bash
docker compose ps
```

---

## WP-CLI Usage

All WP-CLI commands are run via Docker:

```bash
# General format
docker compose run --rm wpcli <command>

# Examples:
docker compose run --rm wpcli plugin list
docker compose run --rm wpcli theme list
docker compose run --rm wpcli user list
docker compose run --rm wpcli post list
```

### Common WP-CLI Commands

```bash
# List all users
docker compose run --rm wpcli user list

# Create a new user
docker compose run --rm wpcli user create johndoe john@example.com \
  --role=editor \
  --display_name="John Doe"

# Activate a plugin
docker compose run --rm wpcli plugin activate plugin-name

# Flush rewrite rules
docker compose run --rm wpcli rewrite flush

# Export database
docker compose run --rm wpcli db export backup.sql

# Search and replace in database
docker compose run --rm wpcli search-replace 'http://oldsite.com' 'http://organicstore.local'
```

---

## Child Theme Best Practices

### What is a Child Theme?

A child theme inherits functionality from a parent theme while allowing customizations that remain update-safe.

### File Structure

```
wp-content/themes/
├── organics/           # Parent theme (DO NOT MODIFY)
└── organics-child/     # Child theme (ALL CUSTOMIZATIONS HERE)
    ├── style.css       # Child theme styles
    ├── functions.php   # Child theme functions
    ├── templates/      # Custom page templates
    ├── template-parts/ # Template overrides
    ├── css/            # Additional stylesheets
    ├── js/             # JavaScript files
    └── inc/            # Include files
```

### Golden Rules

1. **NEVER modify parent theme** (`/wp-content/themes/organics/`)
2. **ALL customizations** go in child theme (`/wp-content/themes/organics-child/`)
3. Use **hooks and filters** instead of direct modifications
4. Override templates by copying to child theme
5. Prefix all custom functions with `organics_child_`

### Example: Overriding a Template

**Wrong** ❌:
```
Editing: wp-content/themes/organics/header.php
```

**Correct** ✅:
```bash
# Copy parent template to child theme
cp wp-content/themes/organics/header.php \
   wp-content/themes/organics-child/header.php

# Now edit the child theme copy
```

---

## Database Access

### Via WP-CLI

```bash
# Open MySQL CLI
docker compose run --rm wpcli db cli

# Or direct query
docker compose run --rm wpcli db query "SELECT * FROM wp_users"
```

### Via MySQL Client

```bash
# Connect to database
docker compose exec db mysql -u wordpress -p organicstore

# Enter password when prompted (from .env: DB_PASSWORD)
```

### Database Backups

```bash
# Export database
docker compose run --rm wpcli db export backup.sql

# Import database
docker compose run --rm wpcli db import backup.sql
```

---

## File Permissions

### Docker Volume Permissions

Docker containers run as `www-data` (UID 33). If you encounter permission issues:

```bash
# Fix ownership (run from project root)
sudo chown -R 33:33 wp-content/
```

**Windows/Mac**: Docker Desktop handles permissions automatically.

---

## Debugging

### Enable WordPress Debug Mode

Already enabled in `wp-config.php`:

```php
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);
```

### View Debug Log

```bash
# Watch debug log in real-time
docker compose exec wordpress tail -f wp-content/debug.log
```

---

## Troubleshooting

### Issue: Cannot access http://organicstore.local

**Cause**: Domain not in hosts file or containers not running

**Solution**:
1. Verify hosts file entry: `127.0.0.1 organicstore.local`
2. Check containers are running: `docker compose ps`
3. Restart containers: `docker compose restart`

### Issue: Database connection error

**Cause**: Database container not ready or wrong credentials

**Solution**:
1. Check containers: `docker compose ps`
2. Verify `.env` credentials match `wp-config.php`
3. Restart database: `docker compose restart db`
4. Wait 10 seconds for database to initialize

### Issue: Permission denied when uploading files

**Cause**: File permissions issue

**Solution**:
```bash
# Fix permissions
docker compose exec wordpress chown -R www-data:www-data /var/www/html/wp-content
```

### Issue: White screen or 500 error

**Cause**: PHP error

**Solution**:
1. Check debug log: `wp-content/debug.log`
2. Check container logs: `docker compose logs wordpress`
3. Verify child theme syntax in `functions.php`

---

## Environment Variables Reference

```bash
# Database Configuration
DB_NAME=organicstore              # Database name
DB_USER=wordpress                 # Database user
DB_PASSWORD=password              # Database password
DB_ROOT_PASSWORD=rootpassword     # MySQL root password
DB_HOST=db:3306                   # Database host (container name)
DB_TABLE_PREFIX=wp_               # WordPress table prefix

# Site Configuration
WP_HOME=http://organicstore.local      # Site home URL
WP_SITEURL=http://organicstore.local   # WordPress URL
WP_DEBUG=1                              # Enable debug mode

# Admin User (for installation)
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=password
WP_ADMIN_EMAIL=admin@organicstore.local

# API Configuration
WP_API_AUTH=username:app_password  # Application password (generate after install)
WP_API_BASE_URL=http://organicstore.local/wp-json
```

---

## Docker Compose Services

### `wordpress` Container
- **Image**: wordpress:php8.3-apache
- **Purpose**: Main WordPress application
- **Ports**: 80:80
- **Volume**: Project root mounted to `/var/www/html`

### `db` Container
- **Image**: mysql:8.0
- **Purpose**: Database server
- **Ports**: 3306:3306
- **Volume**: Named volume `db_data` (persists data)

### `wpcli` Container
- **Image**: wordpress:cli-php8.3
- **Purpose**: WP-CLI command execution
- **Usage**: On-demand (not running continuously)

---

## Performance Tips

### PHP Memory Limit

Already configured in `wp-config.php`:
```php
define('WP_MEMORY_LIMIT', '256M');
define('WP_MAX_MEMORY_LIMIT', '512M');
```

### Object Caching

For production, consider:
- Redis/Memcached plugins
- Transient caching for expensive queries

### Cleanup

Remove unused containers and images:
```bash
docker system prune -a
```

---

## Next Steps

1. ✅ Environment running at http://organicstore.local
2. ✅ WordPress installed
3. ✅ Child theme activated
4. → Generate Application Password for API access (see `/docs/api-access.md`)
5. → Start building features with the multi-agent system

---

**Last Updated**: 2026-01-11
**Maintained By**: Documenter Agent
