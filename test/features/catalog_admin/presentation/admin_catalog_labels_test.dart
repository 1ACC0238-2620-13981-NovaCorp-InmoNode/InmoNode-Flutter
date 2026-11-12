import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/catalog_admin/presentation/admin_catalog_labels.dart';

void main() {
  test('names the statuses in Spanish', () {
    expect(AdminCatalogLabels.projectStatus('DRAFT'), 'Borrador');
    expect(AdminCatalogLabels.projectStatus('PUBLISHED'), 'Publicado');
    expect(AdminCatalogLabels.lotStatus('DRAFT'), 'Borrador');
    expect(AdminCatalogLabels.lotStatus('AVAILABLE'), 'Disponible');
    expect(AdminCatalogLabels.lotStatus('SOLD'), 'Vendido');
    expect(AdminCatalogLabels.lotStatus('ARCHIVED'), 'ARCHIVED');
  });

  test('translates the rules the Web Services explain in English', () {
    const unpublishable = ApiException(
      statusCode: 422,
      code: 'BUSINESS_RULE_VIOLATION',
      message: 'Violación de regla de negocio',
      details: 'A project can be published only once it has at least one lot',
    );
    const crossed = ApiException(
      statusCode: 400,
      code: 'VALIDATION_ERROR',
      message: 'Validación fallida',
      details: 'the boundary polygon crosses itself or has no area',
    );

    expect(AdminCatalogLabels.rejection(unpublishable), 'Registra al menos un lote antes de publicar el proyecto.');
    expect(
      AdminCatalogLabels.rejection(crossed),
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

    final message = AdminCatalogLabels.rejection(unknown);

    expect(message, 'El servidor rechazó los datos. Revisa el formulario e inténtalo de nuevo.');
  });

  test('keeps the Spanish message of other failures', () {
    expect(AdminCatalogLabels.rejection(const ApiException.network()), const ApiException.network().message);
    expect(
      AdminCatalogLabels.rejection(
        const ApiException(statusCode: 404, code: 'PROJECT_NOT_FOUND', message: 'Recurso no encontrado'),
        projectId: 99,
      ),
      'No existe un proyecto con el ID 99.',
    );
  });
}
