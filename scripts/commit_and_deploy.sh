#!/bin/bash

# Script para hacer commit y desplegar automáticamente
# Uso: ./scripts/commit_and_deploy.sh "mensaje del commit"

# Verificar que se proporcione un mensaje de commit
if [ -z "$1" ]; then
    echo "❌ Error: Debes proporcionar un mensaje de commit"
    echo "Uso: ./scripts/commit_and_deploy.sh \"mensaje del commit\""
    exit 1
fi

COMMIT_MESSAGE="$1"

echo "🚀 Iniciando proceso de commit y despliegue automático..."
echo "📝 Mensaje: $COMMIT_MESSAGE"
echo ""

# Verificar que estemos en un repositorio git
if [ ! -d ".git" ]; then
    echo "❌ Error: No estás en un repositorio git"
    exit 1
fi

# Verificar el estado del repositorio
echo "📊 Verificando estado del repositorio..."
git status --porcelain

# Agregar todos los cambios
echo "📦 Agregando cambios al staging..."
git add .

# Verificar si hay cambios para commitear
if git diff --staged --quiet; then
    echo "ℹ️  No hay cambios para commitear"
    exit 0
fi

# Hacer commit
echo "💾 Haciendo commit..."
git commit -m "$COMMIT_MESSAGE"

if [ $? -ne 0 ]; then
    echo "❌ Error al hacer commit"
    exit 1
fi

# Obtener la rama actual
CURRENT_BRANCH=$(git branch --show-current)
echo "🌿 Rama actual: $CURRENT_BRANCH"

# Push a la rama actual
echo "🚀 Haciendo push a origin/$CURRENT_BRANCH..."
git push origin "$CURRENT_BRANCH"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ ¡Commit y push completados exitosamente!"
    echo "🔄 GitHub Actions se ejecutará automáticamente"
    echo "⏱️  El despliegue tomará unos minutos"
    echo ""
    echo "🌐 Una vez completado, tu app estará disponible en:"
    echo "   https://$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\)\/\([^.]*\).*/\1.github.io\/\2/')/"
    echo ""
    echo "📊 Puedes ver el progreso en:"
    echo "   https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\)\/\([^.]*\).*/\1\/\2/')/actions"
else
    echo "❌ Error al hacer push"
    exit 1
fi
