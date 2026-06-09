# Despliegue en Render

## 1. Subir el código a GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/tu-usuario/ContableUxser.git
git push -u origin main
```

## 2. Crear el servicio en Render

1. Ve a https://dashboard.render.com
2. Click **"New +"** → **"Blueprint"** (usa el `render.yaml`) o **"Web Service"**
3. Conecta tu repositorio de GitHub
4. Render detectará automáticamente el `render.yaml` o el `Dockerfile`

### Si usas Web Service (recomendado):
- **Name:** `contableuxser-api`
- **Runtime:** `Docker`
- **Dockerfile Path:** `./src/Dockerfile`
- **Plan:** Free

### Variables de entorno (obligatorio):

| Variable | Valor | Secreta |
|---|---|---|
| `ConnectionStrings__DefaultConnection` | `Host=aws-1-us-west-2.pooler.supabase.com;Port=6543;Database=postgres;Username=postgres.diqividolnzduorgujht;Password=WaFwM2,7Ttsd7ze;SSL Mode=Require;Trust Server Certificate=true;Pooling=true` | ✅ Sí |
| `Jwt__Secret` | `dev-secret-key-not-for-production-use-change-in-deployment-32chars` | ✅ Sí |
| `Jwt__Issuer` | `ContableUxser` | No |
| `Jwt__Audience` | `ContableUxserApp` | No |
| `Jwt__ExpirationHours` | `168` | No |
| `RUN_MIGRATIONS` | `true` | No |
| `ASPNETCORE_ENVIRONMENT` | `Production` | No |

## 3. Obtener la URL de Render

Render te asignará una URL como:
```
https://contableuxser-api.onrender.com
```

## 4. Configurar el Flutter App

Editar `contable_uxser_app/.env`:

```
API_BASE_URL=https://contableuxser-api.onrender.com/api
```

## 5. Generar APK

```powershell
cd contable_uxser_app
./sdkFlutter/flutter/bin/flutter build apk --release
```

El APK estará en `build/app/outputs/flutter-apk/app-release.apk`.

## 6. Probar la API

```bash
# Login
curl -X POST https://contableuxser-api.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@demo.com","password":"admin123"}'

# Productos (con el token del login)
curl -X GET https://contableuxser-api.onrender.com/api/productos \
  -H "Authorization: Bearer TU_TOKEN"
```

## Notas importantes

- El seed data solo se ejecuta si la tabla `Empresas` está vacía
- Para regenerar seed, borra los datos de las tablas en Supabase y reinicia el servicio en Render
- El JWT expira a los 7 días (configurable via `Jwt__ExpirationHours`)
- Swagger se desactiva en producción; activarlo con variable `EnableSwagger=true`
