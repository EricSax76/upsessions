# Funcionalidad de Banner para Eventos

## 📸 Descripción

Se ha implementado la funcionalidad de subir y mostrar un banner personalizado en la página de detalle de eventos, añadiendo un toque de exclusividad visual.

## 🎨 Características Implementadas

### 1. **Modelo de Datos Actualizado**

- ✅ Se agregó el campo `bannerImageUrl` (opcional) a `EventEntity`
- ✅ Se actualizó `EventDto` para soportar la persistencia del banner en Firestore
- ✅ El campo se integra perfectamente con el sistema existente de copyWith y props

### 2. **Servicio de Subida de Imágenes**

**Archivo:** `lib/features/events/data/image_upload_service.dart`

Funcionalidad:

- 📤 Subida de imágenes a Firebase Storage
- 🖼️ Optimización automática (max 1920x1080, calidad 85%)
- 🗑️ Capacidad de eliminación de banners antiguos
- 🏷️ Metadata personalizada (eventId, fecha de subida)
- ⚠️ Manejo robusto de errores

### 3. **UI Premium en Event Detail Page**

#### Banner Widget (`_EventBanner`)

El banner se muestra con un diseño moderno y atractivo:

**Características visuales:**

- **Con imagen:**
  - 🎨 Imagen de fondo a pantalla completa (240px altura)
  - ✨ Overlay de gradiente oscuro para mejor legibilidad
  - 💎 Título con efecto glassmorphism (fondo semi-transparente)
  - 🎭 Sombras de texto para mejor contraste
  - 📝 Botón "Cambiar" con fondo translúcido y borde blanco

- **Sin imagen:**
  - 🌈 Gradiente vibrante usando colores del tema (primary, secondary, tertiary containers)
  - 🖼️ Icono grande y texto motivacional
  - 📤 Botón "Subir banner" destacado
  - 💬 Mensaje: "Dale un toque de exclusividad"

**Interacción:**

- 🔄 Estado de carga visual mientras se sube la imagen
- ✅ Confirmación con SnackBar al completar
- ⚠️ Manejo de errores con mensajes informativos
- 🖱️ Un solo tap para seleccionar y subir

#### Integración en la Página

- El banner aparece **al inicio del detalle del evento**, antes de las cards de información
- Se adapta responsivamente al ancho de pantalla
- Mantiene la restricción de maxWidth 860px para consistencia

## 📝 Flujo de Usuario

1. **Usuario accede al detalle de un evento**
   - Si no hay banner → Ve un placeholder atractivo con gradiente
   - Si hay banner → Ve la imagen con el título del evento superpuesto

2. **Usuario sube un banner**
   - Click en "Subir banner" o "Cambiar"
   - Selecciona imagen de galería
   - La app la sube automáticamente a Firebase Storage
   - Se actualiza el evento en Firestore
   - El banner se muestra inmediatamente

3. **Beneficios**
   - ⭐ Eventos más profesionales y exclusivos
   - 🎯 Mayor engagement visual
   - 📱 Perfecta visualización en todos los dispositivos
   - 💾 Almacenamiento seguro en Firebase

## 🛠️ Archivos Modificados/Creados

### Creados:

- `lib/features/events/data/image_upload_service.dart`

### Modificados:

- `lib/features/events/domain/event_entity.dart`
- `lib/features/events/data/event_dto.dart`
- `lib/features/events/presentation/pages/event_detail_page.dart`

## 🚀 Próximos Pasos Sugeridos

1. **Mejorar la experiencia:**
   - Agregar opción de recortar/editar imagen antes de subir
   - Permitir eliminar el banner existente
   - Cache de imágenes para mejor rendimiento

2. **Analytics:**
   - Trackear cuántos eventos tienen banner
   - Medir engagement con eventos que tienen banner vs sin banner

3. **Compartir:**
   - Usar el banner en las fichas compartidas del evento
   - Incluir banner en exports/PDFs

## ✨ Notas de Diseño

- El diseño usa **glassmorphism** cuando hay imagen, creando un efecto moderno y premium
- Los colores se adaptan automáticamente al tema (dark/light mode)
- El gradiente del placeholder usa 3 colores del tema para máxima armonía
- Las animaciones de loading son sutiles pero informativas
- La elevación de la card es mayor cuando hay imagen (depth visual)
