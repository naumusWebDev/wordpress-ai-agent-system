# Uso del agente Copywriter

## ¿Qué hace?
El agente Copywriter es responsable de generar todos los textos del proyecto WordPress: contenido de páginas, posts, CPTs, campos personalizados, excerpts, títulos SEO y alt de imágenes. Siempre adapta el tono, keywords y contexto según el briefing y la estructura de carpetas de recursos.

## Flujo de integración

1. **Orchestrator** recibe el briefing y genera el JSON de estructura.
2. **Antes de crear cualquier contenido**, el agente Copywriter:
   - Lee el contenido textual del briefing (si existe).
   - Busca en la carpeta de recursos correspondiente (ej: recursos/paginas/contacto/contacto.txt) y, si hay un archivo, lo usa como contenido principal o lo fusiona con el del briefing.
   - Si no hay archivo, genera el contenido desde cero según el contexto.
   - Para imágenes, genera el alt dinámicamente a partir del nombre del archivo y el contexto de la carpeta.
3. **Entrega** el contenido generado al Backend Engineer, Scripter o quien lo solicite para su inserción en WordPress.

## Ejemplo de uso
- Para la página "Contacto":
  - El Copywriter busca recursos/paginas/contacto/contacto.txt. Si existe, lo usa como cuerpo principal. Si no, lo genera.
  - Si el briefing tiene un texto para "Contacto", lo fusiona o lo complementa.
  - Para cada imagen en recursos/paginas/contacto/, genera un alt basado en el nombre del archivo y el contexto (ej: "Mapa de localización de FisioSens").

## Reglas clave
- El contenido de los .txt en recursos tiene prioridad sobre el del briefing, pero ambos pueden combinarse.
- Los alt de imágenes siempre se generan automáticamente, nunca se leen de .txt.
- Si falta contexto, el Copywriter pregunta al Orchestrator.

## Integración en el flujo de agentes
- El Orchestrator debe consultar SIEMPRE al Copywriter antes de crear o importar contenido en WordPress.
- El Backend Engineer y el Scripter deben solicitar al Copywriter los textos y alts antes de insertar nada.
- El Reviewer valida que los textos y alts sean coherentes y estén presentes.

## Ventajas
- Permite enriquecer el contenido con recursos externos sin depender solo del briefing.
- Facilita la colaboración: los PM pueden añadir textos en recursos sin tocar el briefing.
- Garantiza que todas las imágenes tengan alt relevante y contextualizado.
