# InmoNode-Flutter

Aplicación Flutter (Android y Web) de **inmoNode**, desarrollada por NovaCorp. Cubre el portal de autoservicio del **Comprador e Inversionista** y las funciones de **back-office** (catálogo y verificación de comprobantes) descritas en el informe del proyecto.

La operación del Agente Comercial de Campo (EP-01 y EP-02) se desarrolla en la aplicación Android nativa [InmoNode-Mobile](https://github.com/1ACC0238-2620-13981-NovaCorp-InmoNode/InmoNode-Mobile).

- Informe del proyecto: [InmoNode-Project-Report](https://github.com/1ACC0238-2620-13981-NovaCorp-InmoNode/InmoNode-Project-Report)
- Web Services: [InmoNode-Backend](https://github.com/1ACC0238-2620-13981-NovaCorp-InmoNode/InmoNode-Backend) (`https://inmonode-backend.onrender.com/api/v1`)

## Requisitos

- Flutter 3.47 (Dart 3.13) o superior
- Android SDK o Google Chrome

```bash
flutter pub get
flutter run -d chrome     # Web
flutter run               # Dispositivo o emulador Android
flutter analyze
flutter test
```

## Arquitectura

Cada bounded context presente en la aplicación se organiza como un feature dentro de `lib/features/`, con cuatro capas:

| Capa | Contenido |
|---|---|
| `domain` | Entidades, value objects e interfaces de repositorio. Dart puro, sin Flutter ni librerías de red. |
| `application` | Casos de uso (`*_use_case.dart`) que orquestan el dominio. Dart puro. |
| `infrastructure` | Implementaciones de repositorios, APIs remotas (`http`), DTOs y mappers. Los DTOs no salen de esta capa. |
| `presentation` | Páginas, widgets, ViewModels (`ChangeNotifier`) y estados de UI. |

Las dependencias se registran en `lib/core/di/dependency_injection.dart` con `get_it`. Cada feature agrega sus registros en `setupDependencies()`.

```
lib/
├── main.dart
├── core/
│   ├── theme.dart                      # Paleta y tema InmoNode
│   ├── di/dependency_injection.dart    # Registro de dependencias (get_it)
│   ├── network/api_constants.dart      # URL base del backend
│   └── widgets/                        # Componentes compartidos
└── features/
    ├── iam/                            # Cuenta, sesión y roles
    ├── catalog/                        # Exploración de proyectos y lotes
    ├── quotations/                     # Simulador y cotización PDF
    ├── separations/                    # Solicitud de separación web
    ├── vouchers/                       # Comprobantes y Mis Pagos
    ├── contracts/                      # Mis Contratos, conformidad y co-titular
    ├── account_statement/              # Estado de Cuenta, alertas y No Adeudo
    ├── dashboard/                      # Consolidación de activos
    ├── catalog_admin/                  # Back-office: alta y publicación de catálogo
    ├── verifications/                  # Back-office: verificación de comprobantes
    └── main/                           # Navegación principal por rol
```

Ejemplo de un feature completo:

```
features/catalog/
├── domain/            project.dart, lot.dart, project_repository.dart
├── application/       get_projects_use_case.dart
├── infrastructure/    project_repository_impl.dart, remote/project_api.dart, remote/project_dto.dart
└── presentation/      projects_page.dart, projects_view_model.dart, project_card.dart
```

## Planificación

El curso comprende tres Sprints, y todas las historias del Product Backlog se desarrollan dentro de ellos. Esta aplicación se construye completa en el Sprint 2. El Sprint 3 corresponde a la aplicación Android [InmoNode-Mobile](https://github.com/1ACC0238-2620-13981-NovaCorp-InmoNode/InmoNode-Mobile) y a las integraciones externas de los Web Services. De esas integraciones, el pago de cuotas con la pasarela (US-55) también llega a esta aplicación.

### Sprint 2

El objetivo es entregar el autoservicio completo del comprador y el back-office de catálogo y de verificación de comprobantes, en Android y en Chrome, contra los Web Services desplegados en Render. Los Web Services de todas estas historias ya están implementados, así que el trabajo del Sprint es la interfaz y su integración con los endpoints.

| Feature | User Stories | Story Points |
|---|---|---|
| `iam` | US-14 | 5 |
| `catalog` | US-15, US-16 | 8 |
| `quotations` | US-17, US-18 | 8 |
| `separations` | US-19 | 8 |
| `vouchers` | US-20, US-25 | 8 |
| `contracts` | US-21, US-22, US-28 | 11 |
| `account_statement` | US-23, US-24, US-26 | 15 |
| `dashboard` | US-27 | 5 |
| `catalog_admin` | US-51, US-52, US-53 | 10 |
| `verifications` | US-54 | 5 |
| **Total** | **19 historias** | **83** |

En el mismo Sprint, los Web Services completan dos historias técnicas que la aplicación consume: la actualización del estado de los lotes por WebSocket (US-42), en el catálogo, y la paginación (US-46), en los listados de comprobantes. También se realizan los spikes de pasarela, firma y mensajería (US-48, US-30 y US-37). Con estas historias técnicas, el Sprint 2 suma 109 Story Points.

Dependencias entre historias:

- **El inicio de sesión de US-14 se integra primero.** Todo el autoservicio requiere el rol `BUYER`, salvo el catálogo (US-15 y US-16), que es público. El back-office requiere `CATALOG_ADMIN` (US-51 a US-53) o `FINANCE_ADMIN` (US-54).
- **Las cuentas de back-office no se crean desde la aplicación.** Las provee el backend: en desarrollo con los usuarios semilla y en Render con las variables `STAFF_CATALOG_ADMIN_*` y `STAFF_FINANCE_ADMIN_*`.
- **Las historias se integran en el orden de sus flujos:**
  - US-51 → US-52 → US-53 (proyecto, lote y publicación).
  - US-17 → US-18 (simulación y descarga de la cotización).
  - US-19 → US-20 → US-54 → US-25 (separación, comprobante, verificación e historial).
  - US-21 → US-22 (contrato y conformidad).
  - US-23 → US-24, US-26 y US-27 (estado de cuenta, alertas, no adeudo y consolidado).

## Features

### Comprador e Inversionista (rol `BUYER`)

| Feature | Bounded Context | User Stories | Endpoints principales |
|---|---|---|---|
| `iam` | Identidad y Acceso | US-14 Crear cuenta | `POST /auth/register`, `/auth/verify-email`, `/auth/login`, `/auth/refresh`, `/auth/logout` |
| `catalog` | Catálogo Inmobiliario | US-15 Explorar proyectos, US-16 Filtrar lotes en mapa | `GET /projects`, `/projects/{projectId}`, `/projects/{projectId}/lots` |
| `quotations` | Cotización y Separación Digital | US-17 Simular financiamiento, US-18 Descargar cotización | `POST /lots/{lotId}/quotations`, `GET /quotations/{quotationId}`, `/quotations/{quotationId}/download` |
| `separations` | Cotización y Separación Digital | US-19 Solicitar separación web | `POST /lots/{lotId}/separation-requests` |
| `vouchers` | Gestión de Comprobantes | US-20 Adjuntar comprobante, US-25 Historial de recibos validados | `POST /vouchers/upload-url`, `POST /vouchers`, `GET /vouchers`, `GET /reservations/{id}/payment-evidences` |
| `contracts` | Control Financiero y Documental | US-21 Consultar contratos, US-22 Registrar conformidad, US-28 Co-propietario | `GET /reservations/{id}/contract`, `POST /contracts/{contractId}/acknowledgment`, `POST /reservations/{id}/co-owner` |
| `account_statement` | Control Financiero y Documental | US-23 Estado de cuenta, US-24 Alertas de cuotas, US-26 Certificado de no adeudo | `GET /account-statements`, `GET /reservations/{id}/account-statement`, `GET /account-statements/{id}/no-debt-certificate` |
| `dashboard` | Control Financiero y Documental | US-27 Consolidación de activos | `GET /account-statements` |

### Back-office

| Feature | Bounded Context | User Stories | Endpoints principales |
|---|---|---|---|
| `catalog_admin` | Catálogo Inmobiliario (`CATALOG_ADMIN`) | US-51 Alta de proyecto, US-52 Alta de lote, US-53 Publicación de lote | `POST /catalog/projects`, `POST`/`GET /catalog/projects/{projectId}/lots`, `PUT /catalog/projects/{projectId}/publish`, `PUT /catalog/lots/{lotId}/publish` |
| `verifications` | Control Financiero y Documental (`FINANCE_ADMIN`) | US-54 Verificación de comprobantes | `GET /verifications/pending`, `POST /verifications/{evidenceId}/approve`, `POST /verifications/{evidenceId}/reject` |

### Navegación (`main`)

- **Comprador:** Proyectos, Simulador, Estado de Cuenta, Mis Pagos, Mis Contratos y Perfil.
- **Back-office:** Catálogo y Verificaciones.

## Guía de estilo

| Color | Hex | Uso |
|---|---|---|
| Verde Inmobiliario | `#319A4B` | Color primario, acciones principales |
| Verde Claro | `#87C757` | Acento, estado Disponible |
| Negro Puro | `#020202` | Títulos y texto de alta prioridad |
| Blanco Claro | `#F7F8F5` | Fondo y superficies |
| Amarillo Alerta | `#F0F66E` | Advertencias, estados en espera |
| Naranja Terracota | `#E4572E` | Errores, estados Vendido/Rechazado/Vencido |

Tipografía: Josefin Sans (títulos) y Montserrat (cuerpo). Retícula base de 8 px.

## Estrategia de ramas

Se aplica GitFlow:

| Rama | Propósito | Origen | Integración | Nombre |
|---|---|---|---|---|
| `main` | Versiones preparadas para publicación | Inicialización | Recibe release y hotfix | `main` |
| `develop` | Integración del desarrollo | `main` | Recibe feature y correcciones | `develop` |
| feature | Una funcionalidad por rama | `develop` | `develop` | `feature/<story-id>-<short-description>` |
| release | Preparación de versión | `develop` | `main` y `develop` | `release/<MAJOR.MINOR.PATCH>` |
| hotfix | Corrección de versión publicada | `main` | `main` y `develop` | `hotfix/<MAJOR.MINOR.PATCH>` |

Ramas de feature disponibles:

| Rama | Feature |
|---|---|
| `feature/US-14-buyer-account` | `iam` |
| `feature/US-15-project-catalog` | `catalog` |
| `feature/US-16-lot-filters` | `catalog` |
| `feature/US-17-financing-simulation` | `quotations` |
| `feature/US-18-quotation-download` | `quotations` |
| `feature/US-19-separation-request` | `separations` |
| `feature/US-20-voucher-upload` | `vouchers` |
| `feature/US-21-digital-contracts` | `contracts` |
| `feature/US-22-contract-acknowledgment` | `contracts` |
| `feature/US-23-account-statement` | `account_statement` |
| `feature/US-24-installment-alerts` | `account_statement` |
| `feature/US-25-validated-receipts` | `vouchers` |
| `feature/US-26-no-debt-certificate` | `account_statement` |
| `feature/US-27-assets-dashboard` | `dashboard` |
| `feature/US-28-co-owner` | `contracts` |
| `feature/US-51-project-registration` | `catalog_admin` |
| `feature/US-52-lot-registration` | `catalog_admin` |
| `feature/US-53-lot-publication` | `catalog_admin` |
| `feature/US-54-voucher-verification` | `verifications` |

Flujo de trabajo:

1. Actualizar la rama asignada con `develop` antes de empezar (`git pull origin develop`).
2. Trabajar solo dentro de la carpeta del feature correspondiente y registrar sus dependencias en `dependency_injection.dart`.
3. Abrir un Pull Request hacia `develop` y no hacer push directo a `main` ni a `develop`.

## Convenciones

- **Commits:** [Conventional Commits](https://www.conventionalcommits.org/) con el formato `<type>(<scope>): <description>`, usando el feature como scope. Ejemplos: `feat(catalog): show published projects`, `fix(vouchers): reject files over 2 MB`.
- **Versionado:** Semantic Versioning (`MAJOR.MINOR.PATCH`).
- **Código en inglés; textos de interfaz en español.**
- **Dart:** [Effective Dart](https://dart.dev/effective-dart/style). Clases en `UpperCamelCase`, variables y funciones en `lowerCamelCase`, archivos y carpetas en `snake_case`.
- Cada dependencia nueva se agrega con `flutter pub add` en la rama del feature que la necesita.
