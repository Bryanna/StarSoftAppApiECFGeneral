# 🚀 Guía Rápida de Despliegue

## ⚡ Despliegue Automático (Recomendado)

### Opción 1: Commit y Deploy en un solo comando

```bash
./scripts/commit_and_deploy.sh "Tu mensaje de commit"
```

### Opción 2: Commit manual

```bash
git add .
git commit -m "Tu mensaje de commit"
git push origin main
```

**¡Eso es todo!** 🎉 El nuevo workflow optimizado se encarga automáticamente de:

- ✅ Detectar automáticamente el `base-href` correcto
- ✅ Construir la aplicación Flutter para web
- ✅ Usar el sistema oficial de GitHub Pages
- ✅ Optimizar para mejor rendimiento
- ✅ Desplegar de forma más rápida y confiable

- ✅ Construir la aplicación Flutter para web
- ✅ Optimizar los archivos para GitHub Pages
- ✅ Desplegar automáticamente
- ✅ Notificarte cuando esté listo

## 🌐 URLs de Acceso

Una vez desplegado, tu aplicación estará disponible en:

- **Producción:** `https://[tu-usuario].github.io/facturacion/`
- **Repositorio:** `https://github.com/[tu-usuario]/facturacion`
- **Actions:** `https://github.com/[tu-usuario]/facturacion/actions`

## 🔧 Desarrollo Local

### Build y servir localmente:

```bash
./scripts/deploy_web.sh --serve
```

### Solo build:

```bash
./scripts/deploy_web.sh
```

## 📊 Monitoreo del Despliegue

1. Ve a la pestaña **Actions** en tu repositorio de GitHub
2. Verás el workflow "🔄 Auto Deploy on Commit" ejecutándose
3. El proceso toma aproximadamente 2-3 minutos
4. Una vez completado (✅), tu app estará live

## ⚠️ Configuración Inicial (Solo una vez)

### 1. Configurar GitHub Pages

- Ve a **Settings** > **Pages** en tu repositorio
- En **Source**, selecciona **GitHub Actions**

### 2. Configurar Firebase (si usas autenticación)

- Ve a Firebase Console > Authentication > Settings
- Agrega `[tu-usuario].github.io` a dominios autorizados

### 3. Actualizar URLs en el código

- Reemplaza `[tu-usuario]` con tu nombre de usuario real en:
  - `README.md`
  - `DEPLOYMENT.md`
  - `.github/workflows/auto-deploy.yml`

## 🎯 Flujo de Trabajo Típico

```bash
# 1. Hacer cambios en tu código
# 2. Commit y deploy automático
./scripts/commit_and_deploy.sh "Agregué nueva funcionalidad"

# 3. ¡Listo! Tu app se despliega automáticamente
```

## 🆘 Solución de Problemas

### El despliegue falla

- Revisa los logs en GitHub Actions
- Verifica que no haya errores de compilación: `flutter analyze`

### La app no carga

- Verifica que Firebase esté configurado correctamente
- Revisa la consola del navegador para errores

### Cambios no se reflejan

- Espera 2-3 minutos después del commit
- Limpia la caché del navegador (Ctrl+F5)

## 📞 Soporte

Si tienes problemas:

1. Revisa los [Issues](https://github.com/[tu-usuario]/facturacion/issues)
2. Crea un nuevo issue con detalles del problema
3. Incluye los logs de GitHub Actions si es relevante

## 🔧 Solución de Problemas

### ❌ Error "--web-renderer not found"

**✅ Ya corregido** - El workflow ahora usa la sintaxis correcta de Flutter. El parámetro `--web-renderer` fue removido en versiones recientes.

### 🚫 El despliegue falla

- Revisa los logs en GitHub Actions
- Verifica que no haya errores de compilación: `flutter analyze`
- Asegúrate de usar Flutter 3.32.8 o superior

### 🌐 La app no carga

- Verifica que Firebase esté configurado correctamente
- Revisa la consola del navegador para errores
- Verifica que el `base-href` sea correcto

### 🔄 Cambios no se reflejan

- Espera 2-3 minutos después del commit
- Limpia la caché del navegador (Ctrl+F5)
- Verifica que el workflow se haya ejecutado correctamente

### 🔑 Problemas de Firebase

- Agrega tu dominio de GitHub Pages a dominios autorizados
- Verifica que las claves de API sean correctas
- Revisa las reglas de Firestore si usas base de datos
