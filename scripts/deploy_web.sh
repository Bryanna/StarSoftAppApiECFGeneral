#!/bin/bash

# Script para desplegar la aplicación web localmente
# Uso: ./scripts/deploy_web.sh [--serve]

echo "🚀 Iniciando despliegue web..."

# Verificar que Flutter esté instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter no está instalado o no está en el PATH"
    exit 1
fi

# Habilitar soporte web
echo "🔧 Habilitando soporte web..."
flutter config --enable-web

# Obtener dependencias
echo "📦 Obteniendo dependencias..."
flutter pub get

# Limpiar build anterior
echo "🧹 Limpiando build anterior..."
flutter clean

# Construir para web
echo "🏗️ Construyendo aplicación web..."
flutter build web --release --web-renderer html --base-href "/facturacion/"

# Agregar archivos necesarios para GitHub Pages
echo "📄 Preparando archivos para GitHub Pages..."
touch build/web/.nojekyll

# Verificar que la build fue exitosa
if [ $? -eq 0 ]; then
    echo "✅ Build completada exitosamente!"
    echo "📁 Archivos generados en: build/web/"
    echo ""

    # Si se pasa el parámetro --serve, servir automáticamente
    if [ "$1" = "--serve" ]; then
        echo "🌐 Sirviendo aplicación localmente..."
        echo "🔗 Abre tu navegador en: http://localhost:8000"
        echo "⏹️  Presiona Ctrl+C para detener el servidor"
        cd build/web && python -m http.server 8000
    else
        echo "Para servir localmente:"
        echo "  cd build/web && python -m http.server 8000"
        echo "  O ejecuta: ./scripts/deploy_web.sh --serve"
        echo ""
        echo "Para desplegar a GitHub Pages:"
        echo "  git add ."
        echo "  git commit -m 'Deploy to GitHub Pages'"
        echo "  git push origin main"
    fi
else
    echo "❌ Error en la build"
    exit 1
fi
