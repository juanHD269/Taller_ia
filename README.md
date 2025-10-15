# Ocho – Tutor IA con Supabase

Este proyecto Flutter integra:
- Gemini (Google Generative AI) para tutor/sumario.
- Supabase para Login (email/contraseña) y Storage (archivos).

## Configuración

1) Variables de entorno (`.env`):

```
GEMINI_API_KEY=tu_clave_gemini
SUPABASE_URL=https://TU_PROJECT_ID.supabase.co
SUPABASE_ANON_KEY=tu_anon_key
SUPABASE_BUCKET=uploads
```

2) Supabase – Autenticación:
- Crea un proyecto en Supabase y copia `URL` y `anon key`.
- En Auth, decide si el registro requiere confirmación por email. Si está desactivada, la sesión se abre tras registrarse.

3) Supabase – Storage:
- Crea un bucket llamado `uploads` (o el nombre que uses en `SUPABASE_BUCKET`).
- Ajusta las políticas de acceso según tu necesidad (público/privado). Para mostrar URLs públicas, configura el bucket como público o usa políticas que permitan lectura.

## Ejecutar

```
flutter pub get
flutter run -d chrome   # o -d windows / -d android / -d ios
```

## Uso
- Al abrir la app, si no hay sesión se muestra la pantalla de Login.
- Tras iniciar sesión, accede desde Home a:
  - Tutor (chat) y Resumidor (Gemini).
  
Nota: Las consultas y respuestas se guardan automáticamente en Supabase Storage (archivos .txt) en segundo plano. La opción visible "Storage" fue removida del Home.

## Notas
- Si faltan `SUPABASE_URL` o `SUPABASE_ANON_KEY`, la app muestra un aviso y desactiva el login.
- Para producción, revisa las políticas de Storage y reglas de Auth.
