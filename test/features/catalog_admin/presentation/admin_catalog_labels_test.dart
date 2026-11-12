import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog_admin/domain/catalog_rejection.dart';
import 'package:inmonode/features/catalog_admin/domain/project_status.dart';
import 'package:inmonode/features/catalog_admin/presentation/admin_catalog_labels.dart';

void main() {
  test('names the statuses in Spanish', () {
    expect(AdminCatalogLabels.projectStatus(ProjectStatus.draft), 'Borrador');
    expect(AdminCatalogLabels.projectStatus(ProjectStatus.published), 'Publicado');
    expect(AdminCatalogLabels.lotStatus(LotStatus.draft), 'Borrador');
    expect(AdminCatalogLabels.lotStatus(LotStatus.available), 'Disponible');
  });

  test('explains each rejection in Spanish', () {
    expect(AdminCatalogLabels.failure(const ProjectNotFound(99)), 'No existe un proyecto con el ID 99.');
    expect(
      AdminCatalogLabels.failure(const ProjectWithoutLots()),
      'Registra al menos un lote antes de publicar el proyecto.',
    );
    expect(AdminCatalogLabels.failure(const ProjectNotPublished()), 'Publica el proyecto antes de publicar sus lotes.');
    expect(
      AdminCatalogLabels.failure(const LotCodeTaken('N-01')),
      'Ya existe un lote con el código N-01 en este proyecto.',
    );
    expect(
      AdminCatalogLabels.failure(const InvalidLotBoundary(BoundaryProblem.selfIntersecting)),
      'El polígono se cruza consigo mismo o no tiene área. Revisa el orden de los vértices.',
    );
  });

  test('never shows English details it does not know', () {
    const unknown = ApiException(
      statusCode: 400,
      code: 'VALIDATION_ERROR',
      message: 'Validación fallida',
      details: 'Field price: must be greater than 0',
    );

    expect(
      AdminCatalogLabels.failure(unknown),
      'El servidor rechazó los datos. Revisa el formulario e inténtalo de nuevo.',
    );
  });

  test('keeps the Spanish message of other failures', () {
    const forbidden = ApiException(statusCode: 403, code: 'FORBIDDEN', message: 'Acceso denegado');

    expect(AdminCatalogLabels.failure(forbidden), 'Tu cuenta no puede administrar el catálogo.');
    expect(AdminCatalogLabels.failure(const ApiException.network()), const ApiException.network().message);
    expect(AdminCatalogLabels.failure(StateError('boom')), AdminCatalogLabels.unexpected);
  });
}
