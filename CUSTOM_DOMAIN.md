# 🌐 Configuración de Dominio Personalizado

Si quieres usar un dominio personalizado en lugar de `[usuario].github.io/facturacion/`, sigue estos pasos:

## 📋 Pasos para Configurar Dominio Personalizado

### 1. Configurar Variable en GitHub

1. Ve a tu repositorio en GitHub
2. **Settings** > **Secrets and variables** > **Actions**
3. En la pestaña **Variables**, clic en **New repository variable**
4. Nombre: `CUSTOM_DOMAIN`
5. Valor: `tu-dominio.com` (sin https://)

### 2. Configurar DNS

En tu proveedor de DNS, agrega estos registros:

#### Para dominio raíz (ejemplo.com):

```
Tipo: A
Nombre: @
Valor: 185.199.108.153
```

```
Tipo: A
Nombre: @
Valor: 185.199.109.153
```

```
Tipo: A
Nombre: @
Valor: 185.199.110.153
```

```
Tipo: A
Nombre: @
Valor: 185.199.111.153
```

#### Para subdominio (app.ejemplo.com):

```
Tipo: CNAME
Nombre: app
Valor: [tu-usuario].github.io
```

### 3. Configurar en GitHub Pages

1. Ve a **Settings** > **Pages** en tu repositorio
2. En **Custom domain**, ingresa tu dominio
3. Marca **Enforce HTTPS**

### 4. Desplegar

Haz un commit para que el workflow agregue automáticamente el archivo CNAME:

```bash
./scripts/commit_and_deploy.sh "Configurar dominio personalizado"
```

## ✅ Verificación

- El workflow automáticamente creará el archivo `CNAME` en tu sitio
- GitHub verificará la configuración DNS
- Una vez verificado, tu sitio estará disponible en tu dominio personalizado

## 🔧 Solución de Problemas

### El dominio no funciona

- Verifica que los registros DNS estén correctos
- Espera hasta 24 horas para propagación DNS
- Verifica que el archivo CNAME se haya creado en el sitio

### Error de certificado SSL

- Asegúrate de que **Enforce HTTPS** esté habilitado
- GitHub automáticamente genera certificados SSL para dominios personalizados

## 📚 Recursos Adicionales

- [Documentación oficial de GitHub Pages](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)
- [Verificador de DNS](https://www.whatsmydns.net/)
- [Verificador de SSL](https://www.ssllabs.com/ssltest/)
