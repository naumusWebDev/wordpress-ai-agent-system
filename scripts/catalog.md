# WordPress REST API Scripts Catalog

This is the **authoritative index** of all automation scripts in this project.

**Owner**: Scripter Agent (exclusive ownership)
**Last Updated**: 2026-01-11

---

## About This Catalog

### Purpose

This catalog serves as:
- **Registry** of all scripts in `/scripts/wp-api/`
- **Documentation** for script usage
- **Version tracking** for script changes
- **Discovery** tool (find existing scripts before creating new ones)

### Maintenance

- **Owner**: Scripter Agent (exclusive)
- **Updates**: Required when scripts are created, modified, or deleted
- **Format**: Keep consistent with template below

### Before Creating a New Script

1. ✅ **Check this catalog** - Does a similar script exist?
2. ✅ **Can you extend** an existing script instead?
3. ✅ **Is this reusable** or a one-time operation?

---

## Script Categories

- [Content Management](#content-management) - Posts, pages, custom post types
- [User Management](#user-management) - Users, roles, permissions
- [Media Management](#media-management) - Upload, organize media files
- [Data Operations](#data-operations) - Import, export, migrate data
- [Utilities](#utilities) - Helper scripts and tools

---

## Content Management

*No scripts created yet. This section will be populated by the Scripter agent.*

### Example Entry Format

```markdown
### script-name.js

**Purpose**: [One-line description]

**Location**: `/scripts/wp-api/script-name.js`

**Version**: 1.0.0

**Language**: Node.js / Python / Bash

**Prerequisites**:
- Node.js 18+
- Application Password configured
- [Other requirements]

**Environment Variables**:
- `WP_API_BASE_URL` - WordPress REST API base URL
- `WP_API_AUTH` - username:application_password
- [Other variables]

**Usage**:
```bash
node scripts/wp-api/script-name.js [options]

Options:
  --file=FILE    Input file path
  --limit=NUM    Maximum items to process
```

**Examples**:
```bash
# Example 1
node scripts/wp-api/script-name.js --file=data.csv

# Example 2
node scripts/wp-api/script-name.js --file=data.csv --limit=10
```

**Input Format** (if applicable):
```csv
title,content,status
"Post 1","Content here","publish"
"Post 2","More content","draft"
```

**Output**:
- Creates [X] items in WordPress
- Generates `rollback.json` with created IDs

**Rollback**:
```bash
node scripts/wp-api/delete-posts.js --file=rollback.json
```

**Notes**:
- [Important considerations]
- [Limitations]
- [Performance notes]

**Change Log**:
- v1.0.0 (2026-01-11) - Initial version
```

---

## User Management

*No scripts created yet. This section will be populated by the Scripter agent.*

---

## Media Management

*No scripts created yet. This section will be populated by the Scripter agent.*

---

## Data Operations

*No scripts created yet. This section will be populated by the Scripter agent.*

---

## Utilities

*No scripts created yet. This section will be populated by the Scripter agent.*

---

## Common Utilities (Shared)

### API Client Library

**Location**: `/scripts/wp-api/lib/wp-api-client.js` (to be created)

**Purpose**: Reusable WordPress REST API client

**Usage**:
```javascript
const WPAPIClient = require('./lib/wp-api-client');
const api = new WPAPIClient();

// Use in scripts
const posts = await api.getPosts({ per_page: 100 });
```

**Note**: Create this library when you have 3+ scripts to avoid code duplication.

---

## Script Statistics

**Total Scripts**: 0
**By Category**:
- Content Management: 0
- User Management: 0
- Media Management: 0
- Data Operations: 0
- Utilities: 0

**Last Script Added**: N/A
**Last Script Modified**: N/A

---

## Deprecated Scripts

*When scripts are deprecated, they will be documented here with replacement information.*

### Example Deprecation Entry

```markdown
### ~~old-script.js~~ (DEPRECATED)

**Deprecated**: 2026-01-XX
**Reason**: Replaced by new-script.js with better performance
**Replacement**: Use `new-script.js` instead
**Migration**: [How to migrate from old to new]
```

---

## Change History

### 2026-01-11
- Created catalog structure
- Defined categories and templates
- Awaiting first script

---

## Script Submission Checklist

When adding a script to this catalog:

- [ ] Script tested with sample data
- [ ] Environment variables documented
- [ ] Usage examples provided
- [ ] Input/output formats documented
- [ ] Rollback strategy defined (if applicable)
- [ ] Error handling implemented
- [ ] No hardcoded credentials
- [ ] Code follows conventions in `/scripts/README.md`
- [ ] Catalog entry complete and accurate

---

## Finding Scripts

### By Purpose

**Need to create content in bulk?** → Look in [Content Management](#content-management)

**Need to manage users?** → Look in [User Management](#user-management)

**Need to import/export data?** → Look in [Data Operations](#data-operations)

### Search Tips

1. Use your editor's search (Ctrl+F / Cmd+F)
2. Search for keywords: "import", "export", "create", "delete", etc.
3. Check change history for recent additions

---

## Contributing Scripts

### Process

1. **Check catalog** - Avoid duplicates
2. **Develop script** - Follow templates in `/scripts/README.md`
3. **Test thoroughly** - Never skip testing
4. **Document** - Complete catalog entry
5. **Update catalog** - Add to appropriate category
6. **Update statistics** - Increment counts

### Naming Conventions

```
[verb]-[entity/operation].js

Good:
- create-bulk-posts.js
- export-products.js
- delete-old-comments.js

Bad:
- script1.js
- my-script.js
- utility.js
```

---

## Support

### Questions About Existing Scripts

1. Read the catalog entry
2. Check `/scripts/README.md` for general guidance
3. Invoke Scripter agent: `/project:create-wp-api-script`

### Requesting New Scripts

Invoke Scripter agent:
```
/project:create-wp-api-script [describe what you need]
```

Example:
```
/project:create-wp-api-script Create a script to bulk import products from a CSV file with title, price, and description fields
```

---

**Catalog Maintained By**: Scripter Agent
**Exclusive Ownership**: No other agent may modify this file
**Version**: 1.0.0
**Last Updated**: 2026-01-11
