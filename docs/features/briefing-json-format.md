# Formato JSON universal para skills de agentes WordPress

Este documento describe el formato de entrada JSON que deben consumir todas las skills del sistema de agentes. El JSON se genera automáticamente a partir de un briefing rellenado (ejemplo: briefing-template.md) mediante el parser incluido en `scripts/parser-briefing.js`.

## Estructura general

```json
{
  "pages": [
    { "title": "Inicio", "slug": "/", "status": "publish" },
    ...
  ],
  "cpts": [
    {
      "name": "Servicios",
      "slug": "servicios",
      "supports": ["title", "editor", "thumbnail", "excerpt"],
      "acf_fields": [
        { "name": "duracion_sesion", "type": "text", "label": "Duración de la sesión", "required": true },
        ...
      ]
    }
  ],
  "menus": [
    { "name": "Principal", "items": ["Inicio", "Sobre nosotros", ...] },
    ...
  ],
  "bricks_templates": [
    { "name": "Header", "type": "header" },
    ...
  ],
  "acf_field_groups": [
    {
      "title": "Detalles del Servicio",
      "location": [{ "param": "post_type", "value": "servicios" }],
      "fields": [ ... ]
    }
  ],
  "blog_posts": [
    { "title": "...", "excerpt": "...", "content": "...", "categories": ["..."], "status": "publish" },
    ...
  ],
  "legal_pages": [
    { "title": "Política de privacidad", "content": "..." }, ... ]
}
```

## Descripción de cada sección
- **pages**: Páginas a crear (título, slug, estado)
- **cpts**: Custom Post Types (nombre, slug, soportes, campos ACF)
- **menus**: Menús de navegación y sus items
- **bricks_templates**: Plantillas Bricks a crear (nombre, tipo, condiciones)
- **acf_field_groups**: Grupos de campos ACF (opcional, si hay campos complejos)
- **blog_posts**: Entradas de blog a crear (título, contenido, categorías, estado)
- **legal_pages**: Páginas legales con su contenido generado

## Ejemplo de uso
Las skills deben leer este JSON y crear dinámicamente los elementos según la estructura.

---

> El parser puede ampliarse para cubrir nuevas secciones del briefing. Si el briefing incluye más bloques (por ejemplo, usuarios, taxonomías, opciones de tema), se añadirán nuevas claves al JSON siguiendo la misma lógica.
