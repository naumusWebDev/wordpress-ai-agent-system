#!/usr/bin/env node
// parser-briefing.js
// Convierte briefing-template.md (markdown) en briefing-sample.json (estructura universal)

const fs = require('fs');
const path = require('path');

if (process.argv.length < 4) {
  console.error('Uso: node parser-briefing.js <briefing.md> <salida.json>');
  process.exit(1);
}

const [,, briefingPath, outputPath] = process.argv;
const md = fs.readFileSync(briefingPath, 'utf8');

// Funciones simples para extraer secciones (pueden mejorarse con regex más robustas)
function extractSection(title) {
  const regex = new RegExp(`##+\\s*${title}([\s\S]*?)(?=^##+|\n#|\n$)`, 'mi');
  const match = md.match(regex);
  return match ? match[1].trim() : '';
}

function extractPages() {
  const sec = extractSection('2.1 Páginas a Crear');
  const lines = sec.split('\n').filter(l => l.startsWith('|'));
  return lines.slice(2).map(line => {
    const [nombre, slug, estado] = line.split('|').map(s => s.trim()).slice(1,4);
    if (!nombre) return null;
    return { title: nombre, slug, status: estado };
  }).filter(Boolean);
}

function extractCPTs() {
  const sec = extractSection('2.3 Custom Post Types (CPT)');
  const blocks = sec.split('#### CPT').slice(1);
  return blocks.map(block => {
    const name = /Nombre singular:\s*(.*)/.exec(block)?.[1]?.trim();
    const slug = /Slug:\s*(.*)/.exec(block)?.[1]?.trim();
    const supports = /Soporte:\s*([\w, ]+)/.exec(block)?.[1]?.split(',').map(s => s.trim());
    return name && slug ? { name, slug, supports } : null;
  }).filter(Boolean);
}


function extractMenus() {
  const sec = extractSection('2.2 Menús de Navegación');
  const menus = [];
  const menuBlocks = sec.split('####').slice(1);
  menuBlocks.forEach(block => {
    const name = /Nombre del menú:\s*(.*)/.exec(block)?.[1]?.trim();
    const location = /Ubicación:\s*(.*)/.exec(block)?.[1]?.trim();
    const items = Array.from(block.matchAll(/- (.+?) \((.*?)\)/g)).map(m => ({ title: m[1], slug: m[2] }));
    if (name && items.length) menus.push({ name, location, items });
  });
  return menus;
}

function extractACFFieldGroups() {
  const sec = extractSection('2.4 Custom Fields (ACF)');
  const groups = [];
  const groupBlocks = sec.split('####').slice(1);
  groupBlocks.forEach(block => {
    const title = /Grupo de campos: (.*)/.exec(block)?.[1]?.trim();
    const location = /Ubicación:\s*Post Type = ([\w-]+)/.exec(block)?.[1]?.trim();
    const table = block.match(/\| Nombre del campo \|[\s\S]*?\|\s*\n/);
    if (table) {
      const lines = table[0].split('\n').slice(2).filter(l => l.startsWith('|'));
      const fields = lines.map(line => {
        const [name, type, label, required, instructions] = line.split('|').map(s => s.trim()).slice(1,6);
        if (!name) return null;
        return { name, type, label, required: required === 'Sí', instructions };
      }).filter(Boolean);
      if (title && location && fields.length) {
        groups.push({ title, location: [{ param: 'post_type', value: location }], fields });
      }
    }
  });
  return groups;
}

function extractBricksTemplates() {
  const sec = extractSection('2.5 Plantillas Bricks a Crear');
  const templates = [];
  const blocks = sec.split('####').slice(1);
  blocks.forEach(block => {
    const name = /Nombre de la plantilla:\s*(.*)/.exec(block)?.[1]?.trim();
    const type = /Tipo:\s*(.*)/.exec(block)?.[1]?.trim();
    const conditions = /Condiciones de visualización:\s*(.*)/.exec(block)?.[1]?.trim();
    const estado = /Estado:\s*(.*)/.exec(block)?.[1]?.trim();
    if (name && type) templates.push({ name, type, conditions, estado });
  });
  return templates;
}

function extractBlogPosts() {
  const sec = extractSection('4.1 Entradas de Blog');
  // El parser puede mejorarse para extraer ejemplos o instrucciones, aquí solo placeholder
  return [];
}

function extractLegalPages() {
  const sec = extractSection('4.3 Contenido de Páginas Legales');
  const pages = [];
  ['Política de Privacidad', 'Política de Cookies', 'Aviso Legal'].forEach(title => {
    if (sec.includes(title)) pages.push({ title, content: '' });
  });
  return pages;
}

function extractResources() {
  const sec = extractSection('2.6 Recursos');
  const resourcePath = /Ruta raíz de recursos.*?:\s*`?(.*?)`?\s*$/m.exec(sec)?.[1]?.trim() || '';
  // Scan the folder if it exists
  const resources = { path: resourcePath, general: [], paginas: [], entradas: [], cpts: [] };
  if (resourcePath && fs.existsSync(resourcePath)) {
    const scanFolder = (dir, category) => {
      if (!fs.existsSync(dir)) return [];
      const entries = [];
      fs.readdirSync(dir).forEach(sub => {
        const subPath = path.join(dir, sub);
        if (fs.statSync(subPath).isDirectory()) {
          const files = fs.readdirSync(subPath);
          const images = files.filter(f => /\.(webp|png)$/i.test(f));
          const texts = files.filter(f => /\.txt$/i.test(f));
          entries.push({ slug: sub, images, texts, path: subPath });
        }
      });
      return entries;
    };
    // General (flat folder)
    const generalPath = path.join(resourcePath, 'general');
    if (fs.existsSync(generalPath)) {
      resources.general = fs.readdirSync(generalPath).filter(f => /\.(webp|png|ico)$/i.test(f));
    }
    // Paginas
    resources.paginas = scanFolder(path.join(resourcePath, 'paginas'));
    // Entradas
    resources.entradas = scanFolder(path.join(resourcePath, 'entradas'));
    // CPTs (cpt-*)
    fs.readdirSync(resourcePath).filter(d => d.startsWith('cpt-')).forEach(cptDir => {
      const cptSlug = cptDir.replace('cpt-', '');
      const entries = scanFolder(path.join(resourcePath, cptDir));
      resources.cpts.push({ slug: cptSlug, entries });
    });
  }
  return resources;
}


const result = {
  pages: extractPages(),
  cpts: extractCPTs(),
  menus: extractMenus(),
  bricks_templates: extractBricksTemplates(),
  acf_field_groups: extractACFFieldGroups(),
  blog_posts: extractBlogPosts(),
  legal_pages: extractLegalPages(),
  resources: extractResources()
};

fs.writeFileSync(outputPath, JSON.stringify(result, null, 2));
console.log('JSON generado en', outputPath);
