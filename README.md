# Perfil Supabase - Flutter App

Una aplicación Flutter que demuestra la integración completa con Supabase para autenticación y gestión de perfiles de usuario.

## Características

- 🔐 **Autenticación sin contraseñas** con Magic Links
- 👤 **Gestión de perfil** - Editar username y website
- 📸 **Upload de avatares** - Subir fotos de perfil
- 🔗 **Deep Links** - Para callbacks de autenticación
- 🎨 **Tema personalizado** - Interfaz moderna con colores verdes
- 📱 **Responsive** - Funciona en web y móvil

## Tecnologías utilizadas

- **Flutter** - Framework de desarrollo
- **Supabase** - Backend as a Service
- **Supabase Auth** - Autenticación
- **Supabase Storage** - Almacenamiento de imágenes
- **PostgreSQL** - Base de datos (via Supabase)

## Estructura del proyecto

```
lib/
├── components/
│   └── avatar.dart          # Componente reutilizable para avatares
├── pages/
│   ├── login_page.dart      # Página de inicio de sesión
│   └── account_page.dart    # Página de gestión de perfil
└── main.dart               # Punto de entrada de la aplicación
```

## Configuración

### 1. Configurar Supabase

1. Crea un proyecto en [Supabase](https://supabase.com)
2. Crea una tabla `profiles` con las siguientes columnas:
   - `id` (UUID, referencia a auth.users)
   - `username` (text)
   - `website` (text)
   - `avatar_url` (text)
   - `updated_at` (timestamp)

3. Crea un bucket `avatars` en Supabase Storage y configúralo como público

### 2. Configurar la aplicación

1. Actualiza las credenciales en `lib/main.dart`:
```dart
await Supabase.initialize(
  url: 'TU_SUPABASE_URL',
  anonKey: 'TU_SUPABASE_ANON_KEY',
);
```

### 3. Instalar dependencias

```bash
flutter pub get
```

## Ejecutar la aplicación

### Web
```bash
flutter run -d chrome
```

### Android
```bash
flutter run
```

## Funcionalidades

### Autenticación
- Login con Magic Links (sin contraseñas)
- Logout automático
- Navegación condicional basada en estado de autenticación

### Gestión de perfil
- Editar nombre de usuario
- Editar sitio web
- Subir y cambiar foto de perfil
- Actualización automática en base de datos

### Componentes
- Avatar reutilizable con upload de imágenes
- Manejo robusto de errores
- Estados de carga
- Mensajes informativos (SnackBars)

## Arquitectura

La aplicación sigue una arquitectura limpia con:
- Separación de componentes reutilizables
- Manejo centralizado del cliente Supabase
- Extensiones para funcionalidades comunes
- Verificaciones de estado `mounted` para prevenir memory leaks

## Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.