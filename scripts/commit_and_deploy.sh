#!/bin/bash

# Script para hacer commit y desplegar automáticamente
# Uso: ./scripts/commit_and_deploy.sh "mensaje del commit"

# Verificar que se proporcione un mensaje de commit
if [ -z "$1" ]; then
    echo "❌ Error: Debes proporcionar un mensaje de commit"
    echo "💡 Uso: ./scripts/commit_and_deploy.sh \"mensaje del commit\""
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
echo "📊 Verificando cambios..."
git status --short

# Agregar todos los cambios
echo "📦 Agregando cambios..."
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

# Obtener información del repositorio
REPO_URL=$(git config --get remote.origin.url)
REPO_NAME=$(basename -s .git "$REPO_URL")
USER_NAME=$(echo "$REPO_URL" | sed 's/.*github.com[:/]\([^/]*\)\/.*/\1/')
CURRENT_BRANCH=$(git branch --show-current)

echo "🌿 Rama: $CURRENT_BRANCH"
echo "📁 Repositorio: $USER_NAME/$REPO_NAME"

# Push a la rama actual
echo "🚀 Haciendo push..."
git push origin "$CURRENT_BRANCH"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ ¡Commit y push completados exitosamente!"
    echo ""
    echo "🔄 GitHub Actions se ejecutará automáticamente"
    echo "⏱️  El despliegue toma aproximadamente 2-3 minutos"
    echo ""
    echo "🌐 Tu app estará disponible en:"
    echo "   https://$USER_NAME.github.io/$REPO_NAME/"
    echo ""
    echo "📊 Ver progreso del despliegue:"
    echo "   https://github.com/$USER_NAME/$REPO_NAME/actions"
    echo ""
    echo "🎉 ¡Listo! El despliegue automático está en progreso."
else
    echo "❌ Error al hacer push"
    exit 1
fi
