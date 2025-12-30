# Préstamos Corral - Arquitectura Limpia

## 📋 Descripción

Aplicación Flutter para la gestión de préstamos y clientes implementada con **Arquitectura Limpia** (Clean Architecture) y integración con API de Azure.

## 🏗️ Arquitectura Implementada

### Capas de la Arquitectura Limpia

```
lib/
├── core/                          # Núcleo de la aplicación
│   ├── constants/                 # Constantes globales
│   ├── error/                     # Manejo de errores
│   ├── network/                   # Cliente HTTP y conectividad
│   ├── usecases/                  # Casos de uso base
│   └── di/                        # Inyección de dependencias
├── features/                      # Características por módulos
│   ├── auth/                      # Módulo de autenticación
│   │   ├── data/                  # Capa de datos
│   │   │   ├── datasources/       # Fuentes de datos (API, local)
│   │   │   ├── models/            # Modelos de datos (JSON)
│   │   │   └── repositories/      # Implementación de repositorios
│   │   ├── domain/                # Capa de dominio (lógica de negocio)
│   │   │   ├── entities/          # Entidades puras
│   │   │   ├── repositories/      # Contratos de repositorios
│   │   │   └── usecases/          # Casos de uso específicos
│   │   └── presentation/          # Capa de presentación (UI)
│   │       ├── bloc/              # Manejo de estado (BLoC)
│   │       └── pages/             # Páginas de la UI
│   └── clientes/                  # Módulo de clientes
│       └── [misma estructura que auth]
└── main.dart                      # Punto de entrada
```

## 🔧 Tecnologías y Patrones

### Dependencias Principales
- **flutter_bloc**: Manejo de estado reactivo
- **get_it**: Inyección de dependencias
- **dio**: Cliente HTTP avanzado
- **dartz**: Programación funcional (Either)
- **shared_preferences**: Almacenamiento local
- **jwt_decoder**: Decodificación de tokens JWT

### Patrones Implementados
- **Clean Architecture**: Separación clara de responsabilidades
- **Repository Pattern**: Abstracción de fuentes de datos
- **BLoC Pattern**: Manejo de estado predecible
- **Dependency Injection**: Inversión de control
- **Either Pattern**: Manejo funcional de errores

## 🚀 Funcionalidades Implementadas

### ✅ Autenticación JWT
- Login con email y contraseña
- Validación de credenciales
- Almacenamiento seguro de tokens
- Verificación automática de sesión
- Logout con limpieza de datos

### ✅ Gestión de Clientes
- Listar todos los clientes
- Crear nuevos clientes
- Validación de datos (email, teléfono)
- Interfaz intuitiva con tarjetas
- Pull-to-refresh
- Manejo de estados de carga y error

## 🔌 Integración con API

### Endpoints Configurados

#### Autenticación
```
POST /api/Auth/login
Body: {
  "email": "admin@fincorral.com",
  "password": "Admin123!"
}
Response: {
  "token": "jwt_token_here"
}
```

#### Clientes
```
GET /api/ClientesV2
Response: [
  {
    "id": 1,
    "nombre": "Juan Pérez",
    "email": "juan@email.com",
    "telefono": "8712345678",
    "fechaRegistro": "2025-12-27T20:39:52.6319828Z"
  }
]

POST /api/ClientesV2
Body: {
  "nombre": "string",
  "email": "string",
  "telefono": "string"
}
```

## 📱 Navegación y UI

### Estructura de Navegación
1. **Splash Screen**: Verificación de autenticación
2. **Login Page**: Formulario de inicio de sesión
3. **Dashboard**: Navegación principal con tabs
   - Resumen (funcionalidad existente)
   - Clientes (nueva funcionalidad)
   - Préstamos (placeholder)
   - Configuración

### Componentes UI Implementados
- **AuthWrapper**: Manejo automático de navegación por estado
- **ClienteCard**: Tarjeta reutilizable para mostrar clientes
- **Forms**: Validación en tiempo real
- **Loading States**: Indicadores de carga
- **Error Handling**: Mensajes de error amigables

## 🔒 Manejo de Errores

### Tipos de Errores Definidos
```dart
// Errores de dominio
abstract class Failure {
  final String message;
}

class ServerFailure extends Failure {}      // Errores 5xx
class ConnectionFailure extends Failure {}  // Sin internet
class AuthFailure extends Failure {}        // 401, token inválido
class ValidationFailure extends Failure {}  // 400, datos inválidos
class CacheFailure extends Failure {}       // Errores locales
```

### Excepciones de Datos
```dart
class ServerException implements Exception {}
class ConnectionException implements Exception {}
class AuthException implements Exception {}
class ValidationException implements Exception {}
class CacheException implements Exception {}
```

## 🧪 Casos de Uso Implementados

### Autenticación
- **LoginUseCase**: Validación y autenticación
- **LogoutUseCase**: Cierre de sesión seguro

### Clientes
- **GetClientesUseCase**: Obtener lista de clientes
- **CreateClienteUseCase**: Crear cliente con validaciones

## 🔄 Estados de la Aplicación

### Estados de Autenticación
```dart
abstract class AuthState {}
class AuthInitial extends AuthState {}      // Estado inicial
class AuthLoading extends AuthState {}      // Cargando
class AuthAuthenticated extends AuthState {} // Autenticado
class AuthUnauthenticated extends AuthState {} // No autenticado
class AuthError extends AuthState {}        // Error
```

### Estados de Clientes
```dart
abstract class ClientesState {}
class ClientesInitial extends ClientesState {}
class ClientesLoading extends ClientesState {}
class ClientesLoaded extends ClientesState {}
class ClienteCreated extends ClientesState {}
class ClientesError extends ClientesState {}
```

## 🛠️ Configuración y Uso

### 1. Instalación de Dependencias
```bash
flutter pub get
```

### 2. Configuración del API
Las constantes del API están en:
```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'https://prestamoscorrral-gzbbh8fpcpdgesdw.mexicocentral-01.azurewebsites.net/api';
  static const String loginEndpoint = '/Auth/login';
  static const String clientesEndpoint = '/ClientesV2';
}
```

### 3. Credenciales de Prueba
```
Email: admin@fincorral.com
Password: Admin123!
```

### 4. Compilación
```bash
# Android
flutter build apk

# iOS
flutter build ios

# Desarrollo
flutter run
```

## 🔍 Validaciones Implementadas

### Login
- Email requerido y formato válido
- Contraseña requerida
- Validación en tiempo real

### Clientes
- Nombre: mínimo 2 caracteres
- Email: formato válido
- Teléfono: mínimo 10 dígitos numéricos

## 📊 Manejo de Estado

### BLoC Pattern
Cada módulo tiene su propio BLoC para manejar:
- **Eventos**: Acciones del usuario
- **Estados**: Representación del estado actual
- **Transiciones**: Lógica de cambio de estado

### Inyección de Dependencias
```dart
// Configuración en lib/core/di/injection_container.dart
final sl = GetIt.instance;

// Registro de dependencias
sl.registerLazySingleton<ApiClient>(() => ApiClient());
sl.registerFactory(() => AuthBloc(/*...*/));
```

## 🚦 Próximos Pasos

### Funcionalidades Pendientes
1. **Módulo de Préstamos**
   - CRUD completo de préstamos
   - Cálculo de intereses
   - Seguimiento de pagos

2. **Mejoras de UI/UX**
   - Tema personalizable
   - Animaciones
   - Modo offline

3. **Funcionalidades Avanzadas**
   - Notificaciones push
   - Reportes y gráficos
   - Exportación de datos

### Estructura para Nuevos Módulos
Para agregar nuevas funcionalidades, seguir la misma estructura:
```
lib/features/nuevo_modulo/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

## 📝 Notas Importantes

1. **Seguridad**: Los tokens JWT se almacenan de forma segura
2. **Conectividad**: Verificación automática de conexión a internet
3. **Errores**: Manejo centralizado con mensajes amigables
4. **Performance**: Lazy loading de dependencias
5. **Mantenibilidad**: Código bien documentado y estructurado

## 🤝 Contribución

Para contribuir al proyecto:
1. Seguir la arquitectura establecida
2. Documentar nuevas funcionalidades
3. Mantener la separación de responsabilidades
4. Agregar tests unitarios para nuevos casos de uso

---

**Desarrollado con ❤️ usando Flutter y Clean Architecture**