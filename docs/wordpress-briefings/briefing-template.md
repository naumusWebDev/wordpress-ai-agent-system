# 📋 BRIEFING WORDPRESS - AGENTE ORQUESTADOR

> **Proyecto:**  
> **Fecha:**  
> **Responsable:**

---

## 📌 INSTRUCCIONES PARA EL AGENTE

**Interpretación de valores en este briefing:**

- **Campo vacío o sin valor** → Usar configuración por defecto de WordPress
- **Valor específico** → Usar exactamente ese valor
- **"N/A" o "-"** → Este dato no es necesario para el proyecto, omitir

---

## 1. ACCESO TÉCNICO

### Conexión WordPress
- **URL del sitio:**
- **Acceso:** WP-CLI

### Base de Datos
- **Host:**
- **Puerto:** 3306
- **Nombre de la BD:**
- **Usuario:**
- **Contraseña:**
- **Prefijo de tablas:** wp_

### Notas técnicas
- **Tema instalado:** Bricks
- **Plugins instalados:**


---

## 2. ESTRUCTURA DE CONTENIDOS

### 2.1 Páginas a Crear

| Nombre de la página | Slug | Estado |
|---------------------|------|--------|
| Inicio | / | Publicado |
| Sobre nosotros | /sobre-nosotros | Publicado |
| Blog | /blog | Publicado |
| Contacto | /contacto | Publicado |
| Política de privacidad | /politica-privacidad | Publicado |
| Política de cookies | /politica-cookies | Publicado |
| Aviso legal | /aviso-legal | Publicado |

### 2.2 Menús de Navegación

#### Menú Principal (Header)
- **Nombre del menú:** Menu Principal
- **Ubicación:** Primary
- **Items:**
  - Inicio (/)
  - Sobre nosotros (/sobre-nosotros)
  - Blog (/blog)
  - Contacto (/contacto)


#### Menú Footer
- **Nombre del menú:** Menu Footer
- **Ubicación:** Footer
- **Items:**
  - Política de privacidad (/politica-privacidad)
  - Política de cookies (/politica-cookies)
  - Aviso legal (/aviso-legal)


### 2.3 Custom Post Types (CPT)

#### CPT 1: [Nombre del CPT]
- **Nombre singular:**
- **Nombre plural:**
- **Slug:**
- **Público:** Sí
- **Jerárquico:** No
- **Soporte:** title, editor, thumbnail, excerpt
- **Número de entradas de ejemplo a crear:**

#### CPT 2: [Si aplica]
- **Nombre singular:**
- **Nombre plural:**
- **Slug:**
- **Público:** Sí
- **Jerárquico:** No
- **Soporte:** title, editor, thumbnail, excerpt
- **Número de entradas de ejemplo a crear:**

### 2.4 Custom Fields (ACF)

#### Grupo de campos: [Nombre del grupo]
**Ubicación:** Post Type = [slug del CPT]

| Nombre del campo | Tipo | Etiqueta | Requerido | Instrucciones |
|------------------|------|----------|-----------|---------------|
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |

#### Grupo de campos 2: [Si aplica]
**Ubicación:** Post Type = [slug]

| Nombre del campo | Tipo | Etiqueta | Requerido | Instrucciones |
|------------------|------|----------|-----------|---------------|
|  |  |  |  |  |

### 2.5 Plantillas Bricks a Crear

**IMPORTANTE:** Solo crear las plantillas vacías con sus nombres y condiciones. NO diseñar ni añadir contenido.

#### Header
- **Nombre de la plantilla:** Header Principal
- **Tipo:** Header
- **Condiciones de visualización:** Entire Website
- **Estado:** Activo

#### Footer
- **Nombre de la plantilla:** Footer Principal
- **Tipo:** Footer
- **Condiciones de visualización:** Entire Website
- **Estado:** Activo

#### Single Post (Blog)
- **Nombre de la plantilla:** Single - Post Blog
- **Tipo:** Single
- **Condiciones de visualización:** Post Type: Post
- **Estado:** Activo

#### Single CPT 1
- **Nombre de la plantilla:** Single - [Nombre del CPT]
- **Tipo:** Single
- **Condiciones de visualización:** Post Type: [slug del CPT]
- **Estado:** Activo

#### Archive CPT 1
- **Nombre de la plantilla:** Archive - [Nombre del CPT]
- **Tipo:** Archive
- **Condiciones de visualización:** Post Type Archive: [slug del CPT]
- **Estado:** Activo

#### Plantillas adicionales (si aplica)
- **Nombre de la plantilla:**
- **Tipo:**
- **Condiciones de visualización:**
- **Estado:**

---

## 3. TEMÁTICA Y CONTEXTO DEL PROYECTO

### 3.1 Descripción de la Temática

[Describe en 2-4 frases la temática del sitio web]


### 3.2 Público Objetivo

[Breve descripción del público objetivo]


### 3.3 Tono de Comunicación
- [ ] Formal
- [ ] Cercano/Informal
- [ ] Técnico/Profesional
- [ ] Motivacional
- [ ] Otro: ___________

### 3.4 Keywords Principales

[Ejemplo: keyword 1, keyword 2, keyword 3]


---

## 4. GENERACIÓN DE CONTENIDO

### 4.1 Entradas de Blog

**Instrucciones para el agente:**
> Genera **5 entradas de blog** relacionadas con la temática descrita. 
> Cada entrada debe incluir:
> - Título SEO optimizado (máx. 60 caracteres)
> - Contenido de 400-600 palabras
> - Excerpt de 150-160 caracteres
> - Categoría: Blog
> - Estado: Publicado

**Categorías sugeridas:**

[Listar categorías que el agente debe usar o crear]




**Temas sugeridos (opcional):**
[Ejemplos de temas para guiar al agente]


### 4.2 Contenido de CPT

#### CPT: [Nombre del CPT]

**Instrucciones para el agente:**
> Genera **[número] entradas** para el CPT "[nombre]" relacionadas con la temática.

**Ejemplos de entradas a crear:**

[Listar ejemplos o dejar que el agente genere basándose en la temática]


**Para cada entrada de CPT generar:**
- **Título:** [Basado en la temática]
- **Contenido principal:** 200-300 palabras
- **Custom Fields ACF:** Rellenar todos los campos definidos en la sección 2.4 con contenido coherente
- **Excerpt:** 100-120 caracteres
- **Imagen destacada:** Placeholder o imagen relacionada
- **Estado:** Publicado

### 4.3 Contenido de Páginas Legales

**Instrucciones para el agente:**
> Genera contenido básico para las 3 páginas legales requeridas:

#### Política de Privacidad
- Incluir: Datos recogidos, finalidad, derechos del usuario (RGPD), contacto para ejercer derechos
- Longitud: 800-1200 palabras
- Nota: Adaptar a la temática del sitio y legislación española

#### Política de Cookies
- Incluir: Tipos de cookies, finalidad, cómo desactivarlas, cookies de terceros
- Longitud: 600-800 palabras
- Nota: Incluir referencia a banner de consentimiento

#### Aviso Legal
- Incluir: Datos identificativos, condiciones de uso, propiedad intelectual, limitación de responsabilidad
- Longitud: 600-800 palabras
- Nota: Usar datos genéricos marcados como [PLACEHOLDER] para que el cliente complete

---

## 5. CONFIGURACIÓN ADICIONAL

### 5.1 Ajustes de WordPress
- **Página de inicio:** [Página estática o últimas entradas]
- **Página de blog:** [Indicar cuál]
- **Entradas por página:** 10
- **Estructura de permalinks:** /%postname%/

### 5.2 Otras configuraciones

- Deshabilitar comentarios en páginas: [Sí/No]
- Mantener comentarios activos en posts de blog: [Sí/No]
- Configurar zona horaria: [Europe/Madrid u otra]
- Idioma: [Español u otro]
- Formato de fecha: [d/m/Y u otro]
- [Cualquier configuración adicional necesaria]


---

## 6. CRITERIOS DE ÉXITO

**La tarea estará completa cuando:**
- [ ] Todas las páginas especificadas están creadas (incluyendo páginas legales)
- [ ] Menús configurados y asignados a ubicaciones
- [ ] CPTs creados con sus custom fields (ACF)
- [ ] [Número] entradas de cada CPT generadas con contenido coherente
- [ ] 5 entradas de blog generadas con contenido relevante
- [ ] Plantillas Bricks CREADAS (vacías) con nombres y condiciones correctas
- [ ] Campos ACF creados y correctamente configurados
- [ ] Estructura de contenidos navegable y funcional
- [ ] Contenido generado es coherente con la temática
- [ ] Páginas legales creadas con contenido básico

---

## 7. ENTREGABLES ESPERADOS

**El agente debe proporcionar:**

1. ✅ Confirmación de estructura creada
2. 📄 Listado de URLs de páginas creadas (incluyendo legales)
3. 📝 Listado de entradas de blog generadas (títulos y URLs)
4. 🔧 Listado de entradas de CPT generadas (títulos y URLs)
5. 📋 Documentación de custom fields ACF creados
6. 🎨 Listado de plantillas Bricks creadas:
   - Nombre de cada plantilla
   - Tipo (Header/Footer/Single/Archive)
   - Condiciones de visualización configuradas
   - Estado (Activa/Inactiva)
7. 📊 Reporte final con resumen de todo lo implementado

---

## 8. NOTAS ADICIONALES

[Cualquier información extra, restricciones, preferencias, observaciones, etc.]


---

## 9. PRIORIDAD Y TIMELINE

- **Prioridad:** [ ] Baja / [ ] Media / [ ] Alta / [ ] Urgente
- **Deadline:** [Fecha límite]
- **Orden de ejecución:**
  1. Crear estructura (páginas incluyendo legales, CPTs, campos ACF)
  2. Crear plantillas Bricks vacías con nombres y condiciones
  3. Configurar menús
  4. Generar contenido (blog, CPTs, páginas legales)
  5. Verificación final

---

## ✅ CHECKLIST PRE-EJECUCIÓN

- [ ] Accesos técnicos verificados
- [ ] WordPress instalado y funcionando
- [ ] Tema Bricks instalado y activado con licencia
- [ ] Plugin ACF Pro instalado y activado (si se usan custom fields)
- [ ] Otros plugins necesarios instalados
- [ ] Briefing completo y claro
- [ ] Backup realizado (si hay contenido previo)

---

> **Versión:** 1.0  
> **Última actualización:** [Fecha]