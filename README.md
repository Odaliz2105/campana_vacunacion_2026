# 🐾 Campaña de Vacunación Canina y Felina 2026

Una aplicación móvil desarrollada en Flutter para la gestión logística y operativa de campañas de vacunación de mascotas, diseñada para funcionar en entornos con o sin conectividad a internet (Offline-First).

## 🚀 Características Principales

*   **Arquitectura de Roles**: Separa las funciones entre Administradores (Coordinadores) y Vacunadores.
*   **Modo Offline-First**: Si no hay conexión a internet (o si los servidores fallan), la aplicación guarda los registros localmente en el dispositivo usando Hive, permitiendo al vacunador seguir trabajando ininterrumpidamente.
*   **Dashboard Estadístico**: Gráficos en tiempo real que permiten a los administradores monitorear el progreso de la campaña, separando estadísticas por especie (canino/felino) y por sector.
*   **Gestión de Sectores y Usuarios**: Los administradores pueden crear zonas geográficas (sectores) y asignar vacunadores a estas áreas de manera dinámica.

## 📱 Flujo de la Aplicación

La aplicación está dividida en dos grandes flujos de trabajo según el rol del usuario:

### 1. El Administrador (Coordinador de Campaña)
Es el encargado de planificar y supervisar la logística.
1.  **Sectores**: Lo primero que hace el administrador es crear los "Sectores" (ej. Sector Norte, Parque Central).
2.  **Vacunadores**: Una vez creados los sectores, el administrador registra a los Vacunadores en el sistema, y a cada uno le **asigna un sector**.
3.  **Monitoreo**: A través del Dashboard, el administrador puede ver métricas clave (Total de vacunaciones, distribución de perros vs gatos, y métricas segmentadas por cada sector).

### 2. El Vacunador
Es el personal de campo que interactúa con las mascotas.
1.  **Ingreso**: Inicia sesión con las credenciales dadas por el administrador.
2.  **Registro**: Al estar previamente asignado a un sector, el vacunador no pierde tiempo seleccionando dónde está. Llena el formulario rápidamente con los datos de la mascota (nombre, tipo, sexo, edad) y del propietario.
3.  **Trabajo Offline**: Al presionar "Guardar", la aplicación evalúa la conexión. Si no hay internet, guarda el registro de forma segura en la memoria del celular. Si hay internet, lo sincroniza inmediatamente a la nube.

## 🛠️ Tecnologías y Arquitectura

*   **Frontend**: Flutter (Dart) con enfoque en UI moderna.
*   **Backend (BaaS)**: Firebase Authentication y Cloud Firestore.
*   **Persistencia Local**: Hive (Base de datos NoSQL ultrarrápida para Flutter).
*   **Arquitectura**: Clean Architecture simplificada + Provider para inyección de dependencias y manejo de estado.
*   **Patrón Repository**: Se abstrae la lógica de datos, permitiendo un "fallback" inteligente entre `RemoteFirebaseDatasource` y `LocalVaccinationDatasource`.

## ⚙️ Configuración (Para Desarrollo)

1. Clona el repositorio y ejecuta `flutter pub get`.
2. Asegúrate de tener configurado tu proyecto en Firebase.
3. Verifica que las reglas de tu Firestore Database estén configuradas correctamente (`vaccinations`, `users`, `sectors`).
4. Ejecuta con `flutter run`.
