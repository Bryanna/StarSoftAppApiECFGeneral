#!/bin/bash

# Script para probar la build antes del despliegue
# Uso: ./scripts/test_build.sh

echo "🧪 Probando build de Flutter Web..."

# Verificar Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter no encontrado"
    exit 1
fi

echo "📋 Versión de Flutter:"
flutter --version

# Verificar que web esté habilitado
echo "🌐 Habilitando soporte web..."
flutter config --enable-web

# Limpiar y obtener dependencias
echo "🧹 Limpiando proyecto..."
flutter clean
flutter pub get

# Analizar código
echo "🔍 Analizando código..."
flutter analyze --no-fatal-infos

if [ $? -ne 0 ]; then
    echo "⚠️  Hay warnings en el análisis, pero continuando..."
fi

# Probar build
echo "🏗️ Probando build web..."
flutter build web --release

if [ $? -eq 0 ]; then
    echo "✅ Build exitosa!"
    echo "📁 Archivos generados en: build/web/"

    # Verificar archivos importantes
    if [ -f "build/web/index.html" ]; then
        echo "✅ index.html generado"
    else
        echo "❌ index.html no encontrado"
    fi

    if [ -f "build/web/main.dart.js" ]; then
        echo "✅ main.dart.js generado"
    else
        echo "❌ main.dart.js no encontrado"
    fi

    echo ""
    echo "🎉 ¡Todo listo para desplegar!"
    echo "💡 Ejecuta: ./scripts/commit_and_deploy.sh \"mensaje\""

else
    echo "❌ Error en la build"
    echo "💡 Revisa los errores arriba y corrígelos antes de desplegar"
    exit 1
fi
