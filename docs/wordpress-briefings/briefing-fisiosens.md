# Proyecto: FisioSens - Centro de Fisioterapia

**Fecha:** 11/02/2026  
**Responsable:** naumusWebDev

---

## 📌 INSTRUCCIONES PARA EL AGENTE

**Interpretación de valores en este briefing:**

- **Campo vacío o sin valor** → Usar configuración por defecto de WordPress
- **Valor específico** → Usar exactamente ese valor
- **"N/A" o "-"** → Este dato no es necesario para el proyecto, omitir

---

## 1. ACCESO TÉCNICO

### Conexión WordPress
- **URL del sitio:** http://fisiosens.local
- **Ruta WordPress (WSL):** /mnt/c/Users/Sergio Roman/Local Sites/fisiosens/app/public
- **Acceso:** WP-CLI
- **Comando base WP-CLI:** `wp --path="/mnt/c/Users/Sergio Roman/Local Sites/fisiosens/app/public"`

### Base de Datos
- **Host:** 127.0.0.1
- **Puerto:** 10024
- **Nombre de la BD:** local
- **Usuario:** root
- **Contraseña:** root
- **Prefijo de tablas:** wp_



### Notas técnicas
- **Tema instalado:** Bricks
- **Plugins instalados:** ACF , Yoast SEO, Jet form Builder

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

#### CPT 1: Servicios
- **Nombre singular:** Servicio
- **Nombre plural:** Servicios
- **Slug:** servicios
- **Público:** Sí
- **Jerárquico:** No
- **Soporte:** title, editor, thumbnail, excerpt
- **Número de entradas de ejemplo a crear:** 6

#### CPT 2: [Si aplica]
- **Nombre singular:**
- **Nombre plural:**
- **Slug:**
- **Público:** Sí
- **Jerárquico:** No
- **Soporte:** title, editor, thumbnail, excerpt
- **Número de entradas de ejemplo a crear:**
### 2.4 Custom Fields (ACF)

#### Grupo de campos: Detalles del Servicio
**Ubicación:** Post Type = servicios

| Nombre del campo | Tipo | Etiqueta | Requerido | Instrucciones |
|------------------|------|----------|-----------|---------------|
| duracion_sesion | text | Duración de la sesión | Sí | Ej: 60 minutos |
| precio | text | Precio aproximado | No | Ej: 50€ |
| beneficios | textarea | Beneficios principales | Sí | Lista los principales beneficios del tratamiento |
| para_quien | wysiwyg | ¿Para quién está indicado? | No | Describe el público objetivo de este servicio |
| icono_servicio | image | Icono del servicio | No | Imagen cuadrada 200x200px |

#### Grupo de campos 2: [Si aplica]
**Ubicación:** Post Type = [slug]

| Nombre del campo | Tipo | Etiqueta | Requerido | Instrucciones |
|------------------|------|----------|-----------|---------------|
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
- **Nombre de la plantilla:** Single - Servicio
- **Tipo:** Single
- **Condiciones de visualización:** Post Type: servicios
- **Estado:** Activo

#### Archive CPT 1
- **Nombre de la plantilla:** Archive - Servicios
- **Tipo:** Archive
- **Condiciones de visualización:** Post Type Archive: servicios
- **Estado:** Activo

#### Plantillas adicionales (si aplica)
- **Nombre de la plantilla:**
- **Tipo:**
- **Condiciones de visualización:**
- **Estado:**
## 3. TEMÁTICA Y CONTEXTO DEL PROYECTO

### 3.1 Descripción de la Temática
FisioSens es un centro de fisioterapia ubicado en Palma de Mallorca, especializado en rehabilitación deportiva, tratamiento de lesiones musculares, terapias manuales y técnicas avanzadas como punción seca y electroterapia. El público objetivo son deportistas amateur y profesionales, personas con dolores crónicos, lesiones laborales y pacientes en recuperación post-operatoria. Se busca transmitir profesionalidad, confianza y cercanía.

### 3.2 Público Objetivo
- Deportistas (running, ciclismo, crossfit, tenis) 25-45 años
- Personas 35-60 años con dolores crónicos (espalda, cervicales, lumbares)
- Trabajadores de oficina con problemas posturales
- Pacientes post-operatorios en fase de rehabilitación
- Personas mayores con problemas de movilidad
### 3.3 Tono de Comunicación
- [ ] Formal
- [ ] Cercano/Informal
- [x] Técnico/Profesional
- [ ] Motivacional
- [ ] Otro: ___________

### 3.4 Keywords Principales
fisioterapia Mallorca, fisioterapeuta Palma, FisioSens, rehabilitación deportiva Mallorca, tratamiento lesiones musculares, punción seca Palma, terapia manual Mallorca, fisioterapia postural, dolor espalda Mallorca, fisio deportivo Palma

## 4. GENERACIÓN DE CONTENIDO

### 4.1 Entradas de Blog

**Instrucciones para el agente:**

Genera 5 entradas de blog relacionadas con la temática descrita. Cada entrada debe incluir:

- Título SEO optimizado (máx. 60 caracteres)
- Contenido de 400-600 palabras
- Excerpt de 150-160 caracteres
- Categoría: Blog
- Estado: Publicado

**Categorías sugeridas:**
- Consejos de salud
- Lesiones deportivas
- Prevención
- Tratamientos
- Rehabilitación

**Temas sugeridos (opcional):**
- Lesiones más comunes en corredores y cómo prevenirlas
- 5 ejercicios de estiramiento para personas que trabajan en oficina
- Beneficios de la punción seca en el tratamiento de lesiones musculares
- ¿Cuándo debo acudir a un fisioterapeuta? Señales de alerta
- Recuperación post-operatoria: qué esperar de la fisioterapia
### 4.2 Contenido de CPT

**CPT: Servicios**

**Instrucciones para el agente:**

Genera 6 entradas para el CPT "Servicios" relacionadas con la temática.

**Ejemplos de entradas a crear:**
- Rehabilitación deportiva
- Punción seca
- Terapia manual osteopática
- Fisioterapia postural y ergonómica
- Electroterapia y TENS
- Drenaje linfático manual

**Para cada entrada de CPT generar:**
- **Título:** Basado en la temática de fisioterapia
- **Contenido principal:** 250-350 palabras explicando el servicio
- **Custom Fields ACF:** Rellenar todos los campos definidos en la sección 2.4 con contenido coherente
  - duracion_sesion: entre 45-60 minutos
  - precio: entre 40-60€
  - beneficios: 3-5 beneficios principales en formato lista
  - para_quien: 2-3 párrafos describiendo el perfil ideal del paciente
  - icono_servicio: imagen placeholder relacionada
- **Excerpt:** 100-120 caracteres
- **Imagen destacada:** Placeholder de Unsplash relacionado con fisioterapia
- **Estado:** Publicado
### 4.3 Contenido de Páginas Legales

**Instrucciones para el agente:**

Genera contenido básico para las 3 páginas legales requeridas:

#### Política de Privacidad
- **Incluir:** Datos recogidos, finalidad, derechos del usuario (RGPD), contacto para ejercer derechos
- **Longitud:** 800-1200 palabras
- **Nota:** Adaptar a la temática del sitio (centro de fisioterapia) y legislación española (RGPD, LOPD-GDD)

#### Política de Cookies
- **Incluir:** Tipos de cookies, finalidad, cómo desactivarlas, cookies de terceros
- **Longitud:** 600-800 palabras
- **Nota:** Incluir referencia a banner de consentimiento. Texto sugerido para banner: "Este sitio utiliza cookies para mejorar tu experiencia de navegación. Al continuar navegando, aceptas nuestra política de cookies."

#### Aviso Legal
- **Incluir:** Datos identificativos, condiciones de uso, propiedad intelectual, limitación de responsabilidad
- **Longitud:** 600-800 palabras
- **Nota:** Usar datos genéricos marcados como [PLACEHOLDER: FisioSens, NIF/CIF, dirección completa en Palma de Mallorca, email, teléfono] para que el cliente complete
## 5. CONFIGURACIÓN ADICIONAL

### 5.1 Ajustes de WordPress
- **Página de inicio:** Inicio (página estática)
- **Página de blog:** Blog
- **Entradas por página:** 9
- **Estructura de permalinks:** /%postname%/

### 5.2 Otras configuraciones
- Deshabilitar comentarios en páginas
- Mantener comentarios activos en posts de blog
- Configurar zona horaria: Europe/Madrid
- Idioma: Español
- Formato de fecha: d/m/Y
## 6. CRITERIOS DE ÉXITO

La tarea estará completa cuando:

- [ ] Todas las páginas especificadas están creadas (incluyendo páginas legales)
- [ ] Menús configurados y asignados a ubicaciones
- [ ] CPTs creados con sus custom fields (ACF)
- [ ] 6 entradas del CPT Servicios generadas con contenido coherente
- [ ] 5 entradas de blog generadas con contenido relevante
- [ ] Plantillas Bricks CREADAS (vacías) con nombres y condiciones correctas
- [ ] Campos ACF creados y correctamente configurados
- [ ] Estructura de contenidos navegable y funcional
- [ ] Contenido generado es coherente con la temática de FisioSens
- [ ] Páginas legales creadas con contenido básico
## 7. ENTREGABLES ESPERADOS

El agente debe proporcionar:

- ✅ Confirmación de estructura creada
- 📄 Listado de URLs de páginas creadas (incluyendo legales)
- 📝 Listado de entradas de blog generadas (títulos y URLs)
- 🔧 Listado de entradas de CPT generadas (títulos y URLs)
- 📋 Documentación de custom fields ACF creados
- 🎨 Listado de plantillas Bricks creadas:
  - Nombre de cada plantilla
  - Tipo (Header/Footer/Single/Archive)
  - Condiciones de visualización configuradas
  - Estado (Activa/Inactiva)
- 📊 Reporte final con resumen de todo lo implementado
## 8. NOTAS ADICIONALES

- Usar imágenes de Unsplash relacionadas con fisioterapia, deporte y salud
- Términos de búsqueda sugeridos: "physiotherapy", "sports massage", "rehabilitation"
- Todos los CTAs en el contenido deben apuntar a la página /contacto
- Mantener diseño limpio, profesional y moderno en mente (aunque no se diseñe en esta fase)
- Priorizar accesibilidad: textos claros, estructura jerárquica de títulos
- Las plantillas Bricks deben quedar listas para ser editadas visualmente después
- No instalar plugins adicionales sin consultar
- Si hay algún error o imposibilidad técnica, documentar y reportar antes de continuar
- Mencionar "FisioSens" de forma natural en el contenido generado
## 9. PRIORIDAD Y TIMELINE

**Prioridad:** [x] Alta  
**Deadline:** 18/02/2026

**Orden de ejecución:**
1. Crear estructura (páginas incluyendo legales, CPTs, campos ACF)
2. Crear plantillas Bricks vacías con nombres y condiciones
3. Configurar menús
4. Generar contenido (blog, CPTs, páginas legales)
5. Verificación final

## ✅ CHECKLIST PRE-EJECUCIÓN

- [ ] Accesos técnicos verificados
- [ ] WordPress instalado y funcionando
- [ ] Tema Bricks instalado y activado con licencia
- [ ] Plugin ACF Pro instalado y activado (si se usan custom fields)
- [ ] Otros plugins necesarios instalados
- [ ] Briefing completo y claro
- [ ] Backup realizado (si hay contenido previo)

---

**Versión:** 1.0  
**Última actualización:** 11/02/2026