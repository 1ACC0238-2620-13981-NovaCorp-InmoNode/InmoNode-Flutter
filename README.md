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

El curso comprende tres Sprints. El Sprint 2 se desarrolla en esta aplicación. El Sprint 3 corresponde al flujo de campo de [InmoNode-Mobile](https://github.com/1ACC0238-2620-13981-NovaCorp-InmoNode/InmoNode-Mobile): las historias de US-03 a US-13, salvo US-04. Las historias que no caben en los tres Sprints se agrupan en el Release 2, posterior al curso.

### Sprint 2

El objetivo es que el comprador cree su cuenta, explore los proyectos publicados y simule el financiamiento de un lote, y que el administrador de catálogo registre y publique proyectos y lotes, en Android y en Chrome, contra los Web Services desplegados en Render. Los Web Services de US-51, US-52, US-53 y US-15 se entregaron en el Sprint 1; en este Sprint se construye su interfaz.

| User Story | Feature | Story Points | Rama |
|---|---|---|---|
| US-51 Alta de proyecto | `catalog_admin` | 3 | `feature/US-51-project-registration` |
| US-52 Alta de lote con ficha técnica y polígono catastral | `catalog_admin` | 5 | `feature/US-52-lot-registration` |
| US-53 Publicación de lote | `catalog_admin` | 2 | `feature/US-53-lot-publication` |
| US-15 Explorar proyectos | `catalog` | 3 | `feature/US-15-project-catalog` |
| US-17 Simular financiamiento | `quotations` | 5 | `feature/US-17-financing-simulation` |
| US-14 Crear cuenta | `iam` | 5 | `feature/US-14-buyer-account` |
| **Total** | | **23** | |

Las tareas del Sprint (T24 a T46), con su estimación y su responsable, están en el Sprint Backlog 2 del informe (Tabla 4.21) y en el tablero [NovaCorp-InmoNode Sprint 2](https://trello.com/b/ypAZHG4h/novacorp-inmonode-sprint-2) de Trello.

Dependencias entre historias:

- **El inicio de sesión de US-14 se integra primero.** La simulación (US-17) requiere el rol `BUYER`, y el back-office (US-51, US-52 y US-53), el rol `CATALOG_ADMIN`. El catálogo público (US-15) no requiere sesión.
- **US-51, US-52 y US-53 se integran en ese orden.** Un lote se registra dentro de un proyecto, y solo se publica un lote registrado.
- **Las cuentas `CATALOG_ADMIN` no se crean desde la aplicación.** Las provee el backend: en desarrollo con los usuarios semilla y en Render con las variables `STAFF_CATALOG_ADMIN_*`.

## Features

### Comprador e Inversionista (rol `BUYER`)

| Feature | Bounded Context | User Stories | Entrega | Endpoints principales |
|---|---|---|---|---|
| `iam` | Identidad y Acceso | US-14 Crear cuenta | Sprint 2 | `POST /auth/register`, `/auth/verify-email`, `/auth/login`, `/auth/refresh`, `/auth/logout` |
| `catalog` | Catálogo Inmobiliario | US-15 Explorar proyectos, US-16 Filtrar lotes en mapa | Sprint 2 (US-15), Release 2 (US-16) | `GET /projects`, `/projects/{projectId}`, `/projects/{projectId}/lots` |
| `quotations` | Cotización y Separación Digital | US-17 Simular financiamiento, US-18 Descargar cotización | Sprint 2 (US-17), Release 2 (US-18) | `POST /lots/{lotId}/quotations`, `GET /quotations/{quotationId}`, `/quotations/{quotationId}/download` |
| `separations` | Cotización y Separación Digital | US-19 Solicitar separación web | Release 2 | `POST /lots/{lotId}/separation-requests` |
| `vouchers` | Gestión de Comprobantes | US-20 Adjuntar comprobante, US-25 Historial de recibos validados | Release 2 | `POST /vouchers/upload-url`, `POST /vouchers`, `GET /vouchers`, `GET /reservations/{id}/payment-evidences` |
| `contracts` | Control Financiero y Documental | US-21 Consultar contratos, US-22 Registrar conformidad, US-28 Co-propietario | Release 2 | `GET /reservations/{id}/contract`, `POST /contracts/{contractId}/acknowledgment`, `POST /reservations/{id}/co-owner` |
| `account_statement` | Control Financiero y Documental | US-23 Estado de cuenta, US-24 Alertas de cuotas, US-26 Certificado de no adeudo | Release 2 | `GET /account-statements`, `GET /reservations/{id}/account-statement`, `GET /account-statements/{id}/no-debt-certificate` |
| `dashboard` | Control Financiero y Documental | US-27 Consolidación de activos | Release 2 | `GET /account-statements` |

### Back-office

| Feature | Bounded Context | User Stories | Entrega | Endpoints principales |
|---|---|---|---|---|
| `catalog_admin` | Catálogo Inmobiliario (`CATALOG_ADMIN`) | US-51 Alta de proyecto, US-52 Alta de lote, US-53 Publicación de lote | Sprint 2 | `POST /catalog/projects`, `POST`/`GET /catalog/projects/{projectId}/lots`, `PUT /catalog/projects/{projectId}/publish`, `PUT /catalog/lots/{lotId}/publish` |
| `verifications` | Control Financiero y Documental (`FINANCE_ADMIN`) | US-54 Verificación de comprobantes | Release 2 | `GET /verifications/pending`, `POST /verifications/{evidenceId}/approve`, `POST /verifications/{evidenceId}/reject` |

### Navegación (`main`)

- **Comprador:** Proyectos, Simulador, Estado de Cuenta, Mis Pagos, Mis Contratos y Perfil.
- **Back-office:** Catálogo y Verificaciones.

En el Sprint 2 se habilitan Proyectos, Simulador y Perfil para el comprador, y Catálogo para el back-office. Las demás secciones llegan con sus historias en el Release 2.

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

| Rama | Feature | Entrega |
|---|---|---|
| `feature/US-14-buyer-account` | `iam` | Sprint 2 |
| `feature/US-15-project-catalog` | `catalog` | Sprint 2 |
| `feature/US-16-lot-filters` | `catalog` | Release 2 |
| `feature/US-17-financing-simulation` | `quotations` | Sprint 2 |
| `feature/US-18-quotation-download` | `quotations` | Release 2 |
| `feature/US-19-separation-request` | `separations` | Release 2 |
| `feature/US-20-voucher-upload` | `vouchers` | Release 2 |
| `feature/US-21-digital-contracts` | `contracts` | Release 2 |
| `feature/US-22-contract-acknowledgment` | `contracts` | Release 2 |
| `feature/US-23-account-statement` | `account_statement` | Release 2 |
| `feature/US-24-installment-alerts` | `account_statement` | Release 2 |
| `feature/US-25-validated-receipts` | `vouchers` | Release 2 |
| `feature/US-26-no-debt-certificate` | `account_statement` | Release 2 |
| `feature/US-27-assets-dashboard` | `dashboard` | Release 2 |
| `feature/US-28-co-owner` | `contracts` | Release 2 |
| `feature/US-51-project-registration` | `catalog_admin` | Sprint 2 |
| `feature/US-52-lot-registration` | `catalog_admin` | Sprint 2 |
| `feature/US-53-lot-publication` | `catalog_admin` | Sprint 2 |
| `feature/US-54-voucher-verification` | `verifications` | Release 2 |

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
