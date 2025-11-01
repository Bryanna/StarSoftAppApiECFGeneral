# Sistema de Facturación Electrónica

Sistema de gestión de facturas electrónicas desarrollado en Flutter para República Dominicana, compatible con los estándares de la DGII.

## 🌐 Demo en Vivo

La aplicación está desplegada automáticamente en GitHub Pages:
**[Ver Demo](https://[tu-usuario].github.io/facturacion/)**

## ✨ Características

- 📱 Multiplataforma (Web, iOS, Android, macOS, Windows)
- 🔐 Autenticación con Firebase
- 📊 Gestión de facturas electrónicas
- 🏷️ Tabs dinámicos por tipo de comprobante
- 📄 Generación de PDFs
- 🔄 Sistema de cola para envío automático
- 🎨 Interfaz moderna con Material Design

## 🚀 Despliegue Automático

¡Despliegue automático configurado! Cada commit se despliega automáticamente a GitHub Pages.

### ⚡ Uso Rápido

```bash
# Commit y deploy en un solo comando
./scripts/commit_and_deploy.sh "Tu mensaje de commit"

# O manualmente
git add .
git commit -m "Tu mensaje"
git push origin main
```

**¡Eso es todo!** GitHub Actions se encarga del resto automáticamente.

### 📋 Configuración Inicial (Solo una vez)

1. **GitHub Pages:** Settings > Pages > Source: **GitHub Actions**
2. **Firebase:** Agregar `[tu-usuario].github.io` a dominios autorizados
3. **URLs:** Reemplazar `[tu-usuario]` con tu nombre real en los archivos

Ver [Guía Rápida](QUICK_START.md) para más detalles.

## 🛠️ Desarrollo Local

### Prerrequisitos

- Flutter SDK (versión 3.32.8 o superior)
- Dart SDK
- Cuenta de Firebase configurada

### Instalación

```bash
# Clonar el repositorio
git clone https://github.com/[tu-usuario]/facturacion.git
cd facturacion

# Instalar dependencias
flutter pub get

# Ejecutar en modo desarrollo
flutter run
```

### Build para Web

```bash
# Habilitar soporte web (solo la primera vez)
flutter config --enable-web

# Build para producción
flutter build web --release

# O usar el script automatizado
./scripts/deploy_web.sh
```

## 📱 Plataformas Soportadas

- ✅ Web (GitHub Pages)
- ✅ Android
- ✅ iOS
- ✅ macOS
- ✅ Windows
- ⚠️ Linux (configuración pendiente)

## 🔧 Configuración

### Firebase

1. Crear proyecto en [Firebase Console](https://console.firebase.google.com/)
2. Habilitar Authentication y Firestore
3. Configurar dominios autorizados para GitHub Pages
4. Actualizar `lib/firebase_options.dart` si es necesario

### Variables de Entorno

El proyecto usa Firebase para la configuración, no requiere variables de entorno adicionales.

## 📚 Documentación

- [Guía de Despliegue](DEPLOYMENT.md)
- [Configuración de Firebase](docs/firebase-setup.md)
- [API Documentation](docs/api.md)

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

## 👥 Equipo

- **StarSoft Dominicana** - Desarrollo principal

## 🆘 Soporte

Si tienes problemas o preguntas:

1. Revisa la [documentación](DEPLOYMENT.md)
2. Busca en los [Issues](https://github.com/[tu-usuario]/facturacion/issues)
3. Crea un nuevo issue si es necesario
