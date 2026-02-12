# Development Environment Setup

How to configure the WordPress development environment for this project.

---

## Supported Modes

This framework supports **two** modes of operation. Choose one:

| Mode | Best for | WP-CLI via | Infrastructure |
|------|----------|------------|----------------|
| **Docker** | Fresh projects, CI/CD, portable | `docker compose run --rm wpcli` | docker-compose.yml |
| **Local WP** | Windows users, visual admin, existing sites | `wp` in WSL | Local by Flywheel |

Both modes are fully compatible with the agent system and automation scripts.

---

## Mode 1: Docker

### Prerequisites

- **Docker Desktop** (Windows/Mac) or **Docker Engine** (Linux)
- **Docker Compose** v2.0+
- **Git**
- **Node.js 18+** (optional — for REST API scripts)

### 1. Configure hosts file

Add your local domain to the hosts file:

**Windows** (`C:\Windows\System32\drivers\etc\hosts`):
**Linux/Mac** (`/etc/hosts`):
```
127.0.0.1 myproject.local
```

### 2. Create environment file

```bash
cp .env.example .env
```

Edit `.env`:

```bash
DB_NAME=myproject
DB_USER=wordpress
DB_PASSWORD=your_secure_password
DB_ROOT_PASSWORD=your_root_password

WP_HOME=http://myproject.local
WP_SITEURL=http://myproject.local

WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=your_admin_password
WP_ADMIN_EMAIL=admin@myproject.local
```

### 3. Start containers

```bash
docker compose up -d
```

### 4. Install WordPress

**Browser**: Visit `http://myproject.local` and follow the wizard.

**WP-CLI**:
```bash
docker compose run --rm wpcli core install \
  --url="http://myproject.local" \
  --title="My Project" \
  --admin_user="admin" \
  --admin_password="your_password" \
  --admin_email="admin@myproject.local"
```

### 5. Activate child theme

```bash
docker compose run --rm wpcli theme activate your-child-theme
```

### 6. Verify

```bash
docker compose ps                                  # containers running
docker compose run --rm wpcli option get siteurl    # correct URL
curl -s http://myproject.local | head -5            # site responds
```

### Docker commands reference

```bash
docker compose up -d          # start containers
docker compose down           # stop containers
docker compose logs -f        # tail logs
docker compose restart        # restart all
docker compose ps             # container status
```

### WP-CLI via Docker

```bash
docker compose run --rm wpcli <command>
# Examples:
docker compose run --rm wpcli plugin list
docker compose run --rm wpcli theme list
docker compose run --rm wpcli user list
```

---

## Mode 2: Local WP (by Flywheel)

### Prerequisites

- **Local WP** installed — [localwp.com](https://localwp.com/)
- **WSL** (Windows only) with WP-CLI installed
- **Git**
- **Node.js 18+** (optional — for REST API scripts)

### 1. Create a site in Local WP

1. Open Local WP → **Create a new site**
2. Set the domain (e.g. `myproject.local`)
3. Choose PHP version and web server
4. Complete setup

Note the WordPress root path. Typical locations:
- **Windows**: `C:\Users\<user>\Local Sites\<site>\app\public`
- **Mac**: `~/Local Sites/<site>/app/public`

### 2. Install WP-CLI in WSL (Windows)

```bash
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
wp --info
```

### 3. Verify WP-CLI can reach Local WP

From WSL, the Windows filesystem is accessible at `/mnt/c/`. Test:

```bash
wp --path="/mnt/c/Users/<user>/Local Sites/<site>/app/public" option get siteurl
```

If this returns the site URL, WP-CLI is connected.

### 4. Create environment file

```bash
cp .env.example .env
```

Edit `.env`:

```bash
# Path to WordPress installation (required for WP-CLI scripts)
WP_PATH="/mnt/c/Users/<user>/Local Sites/<site>/app/public"

# REST API (optional — only if using wp-api scripts)
WP_API_BASE_URL=http://myproject.local/wp-json
WP_API_USER=admin
WP_API_PASSWORD=your_application_password
```

### 5. Verify

```bash
wp --path="$WP_PATH" option get siteurl     # correct URL
wp --path="$WP_PATH" theme list             # themes installed
curl -s http://myproject.local | head -5     # site responds
```

---

## Configure Agent Variables

After your environment is running, configure the agent system:

1. Copy the template:
   ```bash
   cp agents/VARIABLES.example.md agents/VARIABLES.md
   ```

2. Edit `agents/VARIABLES.md` with your project-specific values:
   - Project name, domain, description
   - WordPress path (for Local WP mode)
   - Theme names (parent and child)
   - Plugin list
   - Content structure

`VARIABLES.md` is gitignored — each contributor maintains their own copy.

---

## Running Automation Scripts

### WP-CLI scripts

```bash
# Docker mode
./scripts/wp-cli/create-pages.sh \
  --wp-path="docker" \
  --file=data/myproject/pages.json

# Local WP mode
./scripts/wp-cli/create-pages.sh \
  --wp-path="/mnt/c/Users/<user>/Local Sites/<site>/app/public" \
  --file=data/myproject/pages.json
```

### REST API scripts

```bash
source .env
node scripts/wp-api/create-post.js --title="Test" --status=draft
```

See [api-access.md](api-access.md) for REST API authentication setup.

---

## Troubleshooting

| Problem | Docker mode | Local WP mode |
|---------|-------------|---------------|
| Site not loading | `docker compose ps` — check containers | Ensure site is running in Local WP |
| WP-CLI not found | Use `docker compose run --rm wpcli` | Install WP-CLI in WSL |
| Permission denied | Check Docker socket permissions | Run WSL as normal user |
| DB connection error | Check `.env` credentials | Local WP manages DB automatically |
| Can't resolve domain | Add to hosts file | Local WP usually handles DNS via router |
