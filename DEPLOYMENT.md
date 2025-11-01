# Despliegue en GitHub Pages

Este proyecto está configurado para desplegarse automáticamente en GitHub Pages usando GitHub Actions.

## Configuración Automática

El despliegue se ejecuta automáticamente cuando:

- Se hace push a la rama `main` o `master`
- Se crea un Pull Request hacia estas ramas

## URL de Acceso

Una vez desplegado, la aplicación estará disponible en:

```
https://[tu-usuario].github.io/facturacion/
```

## Configuración Manual (si es necesario)

### 1. Habilitar GitHub Pages

1. Ve a tu repositorio en GitHub
2. Navega a **Settings** > **Pages**
3. En **Source**, selecciona **GitHub Actions**

### 2. Verificar el Despliegue

1. Ve a la pestaña **Actions** en tu repositorio
2. Verifica que el workflow "Deploy to GitHub Pages" se ejecute correctamente
3. Una vez completado, tu aplicación estará disponible en la URL mencionada arriba

## Configuración Local para Pruebas

Para probar la build web localmente:

```bash
# Habilitar soporte web (solo la primera vez)
flutter config --enable-web

# Instalar dependencias
flutter pub get

# Construir para web
flutter build web --release

# Servir localmente (opcional)
cd build/web
python -m http.server 8000
```

## Notas Importantes

- La aplicación usa Firebase, asegúrate de que la configuración de Firebase esté correcta para el dominio de GitHub Pages
- El `base-href` está configurado como `/facturacion/` para coincidir con el nombre del repositorio
- Si cambias el nombre del repositorio, actualiza el `base-href` en el workflow de GitHub Actions

## Solución de Problemas

### Error 404 al acceder a rutas específicas

GitHub Pages no maneja las rutas SPA automáticamente. Para solucionarlo:

1. Asegúrate de usar `HashRouter` en lugar de `BrowserRouter` si es aplicable
2. O configura un archivo `404.html` que redirija al `index.html`

### Problemas con Firebase

Si tienes problemas con Firebase en GitHub Pages:

1. Verifica que el dominio `[tu-usuario].github.io` esté autorizado en la configuración de Firebase
2. Actualiza las reglas de CORS si es necesario
3. Revisa la configuración de autenticación de Firebase para dominios autorizados
