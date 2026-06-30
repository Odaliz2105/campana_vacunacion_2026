# 🐶🐱 Campaña de Vacunación Canina y Felina 2026

Sistema móvil desarrollado en Flutter para la gestión logística y operativa de campañas municipales de vacunación para perros y gatos.

El sistema implementa un esquema de acceso basado en roles jerárquicos, permitiendo administrar sectores, coordinadores, vacunadores y registros de vacunación con soporte **offline-first**, almacenamiento local seguro y sincronización en tiempo real mediante Firebase.

## 👩‍💻 Autora / Desarrolladora
*   👩 Odaliz Balseca Valencia 
## 🚀 Tecnologías utilizadas

| Tecnología | Uso |
| :--- | :--- |
| **Flutter & Dart** | Desarrollo de la aplicación móvil (Frontend UI/UX) |
| **Firebase Authentication** | Autenticación segura y control de accesos por roles |
| **Cloud Firestore** | Base de datos NoSQL en la nube |
| **Firebase Storage** | Almacenamiento de fotografías de las mascotas |
| **Hive** | Persistencia local NoSQL ultrarrápida (Modo Offline) |
| **Geolocator** | Obtención automática de coordenadas GPS en campo |
| **Image Picker** | Captura de fotografías desde la cámara |
| **Provider** | Inyección de dependencias y gestión del estado |

## 👥 Roles del sistema

| Rol | Funciones |
| :--- | :--- |
| 👨‍💼 **Coordinador de Campaña (Admin)** | Gestiona sectores, crea cuentas para coordinadores de brigada y visualiza estadísticas globales en su Dashboard. |
| 👷 **Coordinador de Brigada** | Administra los vacunadores de su zona asignada, revisa registros y consulta los indicadores específicos de su brigada. |
| 💉 **Vacunador** | Registra vacunaciones en campo, captura fotografía y ubicación GPS. Su interfaz está optimizada para rapidez y funciona sin internet. |

## ✨ Funcionalidades principales

*   ✅ **Inicio de sesión con autenticación basada en roles** (Enrutamiento dinámico).
*   ✅ **Cambio obligatorio de contraseña** en el primer ingreso por seguridad.
*   ✅ **Recuperación de contraseña** integrada.
*   ✅ **CRUD completo** de usuarios y sectores según los permisos del rol.
*   ✅ **Captura automática de datos de campo:**
    *   📷 Fotografía de la mascota
    *   📍 Coordenadas GPS exactas
    *   🕒 Fecha y hora automáticas
*   ✅ **Dashboard Estadístico Dinámico** con gráficas e indicadores por:
    *   Total de vacunaciones
    *   Especies (Canino / Felino)
    *   Rendimiento por Sectores
*   ✅ **Funcionamiento Offline-First:** Uso de Hive local como capa de seguridad si falla la red, con sincronización posterior.
*   ✅ **Splash Screen personalizado.**
*   ✅ **Ícono nativo para Android** (Generado con `flutter_launcher_icons`).

## ⚙️ Instalación y Configuración

### 1️⃣ Clonar el repositorio
```bash
git clone [URL_DE_TU_REPOSITORIO_AQUI]
```

### 2️⃣ Instalar dependencias
```bash
flutter pub get
```

### 3️⃣ Inicializar Firebase
Asegúrate de que el archivo `firebase_options.dart` esté generado y configurado en `lib/main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  await Hive.openBox<String>(AppConstants.hiveBoxVaccinations);
  runApp(const MyApp());
}
```

## 🎨 Personalización de la aplicación

### 📱 Ícono de la App
El ícono moderno de perro y gato fue configurado mediante `flutter_launcher_icons`. Para regenerarlo:
```bash
flutter pub run flutter_launcher_icons
```

## ▶️ Ejecución

**Ejecutar la aplicación en modo debug:**
```bash
flutter run
```

**Generar APK para producción:**
```bash
flutter build apk --release
```

## 🔐 Credenciales de prueba

| Rol | Usuario | Contraseña |
| :--- | :--- | :--- |
| 👨‍💼 **Coordinador de Campaña** | `admin@vacunacion.com` | `12345678` *(o la clave que hayas configurado)* |
| 👷 **Coordinador de Brigada** | *(crear uno de prueba)* | `Ecuador2026` |
| 💉 **Vacunador** | *(crear uno de prueba)* | `Ecuador2026` |

*(Nota: En producción, el sistema exige el cambio de la clave genérica "Ecuador2026").*

## ✅ Resultados obtenidos y Valor Agregado
1. **Logística Digitalizada:** Eliminación de los registros en papel.
2. **Control Georreferenciado:** Ubicación GPS automática para rastrear exactamente dónde se aplicó cada vacuna.
4. **Dashboards en Tiempo Real:** Toma de decisiones informada para los coordinadores municipales.

## Base de Datos en Firebase


## Link del Video Youtube 

## Link APK 

## 📷 Capturas del sistema

Splash Screen 
Ícono 


Login 
Dashboard 


Gestión de Sectores 
Creación de Sectores 


Coordinadores de Brigada 
Formulario para Coordinador 


| Formulario de Vacunación | Fotografía y GPS |
| :---: | :---: |
| *[imagen]* | *[imagen]* |
