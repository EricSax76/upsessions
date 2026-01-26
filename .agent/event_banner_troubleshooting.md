# 🔧 Troubleshooting: Banner de Eventos

## ✅ Cambios Realizados

### 1. **Servicio de Imágenes Actualizado**

- ✅ Ahora usa `readAsBytes()` en lugar de `File()` (funciona en web y móvil)
- ✅ Logs detallados con emojis para fácil debugging
- ✅ Monitoreo de progreso de subida
- ✅ Errores se re-lanzan para mostrarlos en la UI

### 2. **Permisos Agregados**

#### iOS (`ios/Runner/Info.plist`):

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso a tu galería para subir banners de eventos</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Necesitamos acceso a tu galería para guardar imágenes</string>
<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a la cámara para tomar fotos de eventos</string>
```

#### Android (`android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

### 3. **UI con Mejor Feedback**

- ✅ SnackBars con colores (verde para éxito, rojo para error)
- ✅ Duración apropiada de mensajes
- ✅ Botón "Ver detalles" en errores

## 🧪 Cómo Testear

### Paso 1: Reiniciar la App

**IMPORTANTE**: Debes reiniciar completamente la app para que los permisos se apliquen:

```bash
# iOS
flutter run

# o Android
flutter run
```

### Paso 2: Ver los Logs

Abre la consola de Flutter y busca estos mensajes al intentar subir un banner:

```
🎯 [EventDetail] Iniciando proceso de subida de banner
🎨 [ImageUpload] Iniciando selección de imagen para evento: <eventId>
✅ [ImageUpload] Imagen seleccionada: <nombre>, tamaño: <bytes> bytes
📤 [ImageUpload] Iniciando subida a: events/banners/<filename>
📊 [ImageUpload] Bytes leídos: <número>
📈 [ImageUpload] Progreso: XX.X%
✅ [ImageUpload] Subida completada
🔗 [ImageUpload] URL obtenida: <url>
💾 [EventDetail] Guardando evento actualizado en Firestore
🎉 [EventDetail] Banner actualizado exitosamente
```

### Paso 3: Verificar Permisos

#### En iOS:

1. Cuando toques "Subir banner", debería aparecer un popup pidiendo permiso
2. Si no aparece, ve a **Configuración > [Tu App] > Fotos** y verifica los permisos

#### En Android:

1. Similar a iOS, debe pedir permiso la primera vez
2. Ve a **Configuración > Apps > [Tu App] > Permisos** para verificar

## 🐛 Problemas Comunes

### Problema 1: No aparece el selector de imágenes

**Solución:**

1. Asegúrate de haber reiniciado la app completamente
2. Verifica que los permisos estén en los archivos manifest/plist
3. En iOS, si ya negaste el permiso antes, debes ir a Configuración y habilitarlo manualmente
4. Desinstala y reinstala la app para resetear permisos

### Problema 2: Error "PlatformException"

Si ves un error tipo `PlatformException(photo_access_denied, ...)`

**Solución:**

```bash
# iOS: Desinstalar app y reinstalar
flutter clean
flutter run

# Android: Limpiar permisos
adb shell pm clear <package_name>
flutter run
```

### Problema 3: No se ve nada en consola

**Solución:**

1. Asegúrate de estar corriendo en modo debug: `flutter run`
2. Verifica que la consola esté visible en tu IDE
3. En web, abre las DevTools del navegador (F12)

### Problema 4: La imagen no se guarda en Firestore

**Posibles causas:**

- Firebase Storage no está configurado correctamente
- Reglas de seguridad de Storage muy restrictivas
- Firestore reglas no permiten actualizar eventos

**Verificar reglas de Firebase Storage:**

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /events/banners/{fileName} {
      // Permitir lectura a todos
      allow read: if true;
      // Permitir escritura solo a usuarios autenticados
      allow write: if request.auth != null;
    }
  }
}
```

### Problema 5: "No hace nada" al seleccionar imagen

Revisa los logs y busca:

- ❌ Símbolos de error
- El lugar exacto donde falla

Comandos útiles:

```bash
# Ver todos los logs
flutter logs

# Limpiar y reconstruir
flutter clean
flutter pub get
flutter run
```

## 📱 Testing en Diferentes Plataformas

### Web

```bash
flutter run -d chrome
```

- Abre las DevTools del navegador (F12)
- Ve a la pestaña Console para ver los debugPrint
- Puede que necesites dar permisos al navegador

### iOS Simulator

```bash
flutter run -d "iPhone 15 Pro"
```

- Los logs aparecen en la consola de Flutter
- El simulador puede acceder a la galería de fotos del Mac

### Android Emulator

```bash
flutter run -d emulator-5554
```

- Los logs aparecen en la consola
- Agrega fotos al emulador: arrastra archivos a la ventana

### Dispositivo Físico

```bash
# iOS
flutter run -d <device-id>

# Android
flutter run -d <device-id>
```

## 🔍 Debug Checklist

- [ ] He reiniciado completamente la app
- [ ] Veo los logs con emojis 🎯 en la consola
- [ ] Los permisos están en Info.plist (iOS) o AndroidManifest.xml (Android)
- [ ] Firebase Storage está habilitado en la consola de Firebase
- [ ] Las reglas de Storage permiten escritura
- [ ] El evento tiene un ID válido
- [ ] Estoy usando un usuario autenticado (si las reglas lo requieren)

## 📞 Solución Rápida

Para un test rápido completo:

```bash
# 1. Limpiar todo
flutter clean

# 2. Reinstalar dependencias
flutter pub get

# 3. Correr en dispositivo/emulador
flutter run

# 4. Ir a un evento
# 5. Tocar "Subir banner"
# 6. Ver la consola para logs con 🎯 🎨 📤 etc.
```

## 💡 Tips Adicionales

1. **Verifica Firebase Console**: Ve a Storage en Firebase Console y asegúrate de que la carpeta `events/banners/` se crea cuando subes
2. **Prueba con imagen pequeña primero**: Usa una imagen de < 1MB para probar más rápido
3. **Revisa la conexión**: Asegúrate de tener internet para conectar a Firebase
4. **Modo debug**: Siempre prueba en modo debug primero, no en release
