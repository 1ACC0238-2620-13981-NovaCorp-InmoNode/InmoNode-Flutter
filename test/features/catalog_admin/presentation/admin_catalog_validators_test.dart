import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/catalog_admin/presentation/admin_catalog_validators.dart';

void main() {
  test('asks for required text within its length', () {
    expect(AdminCatalogValidators.requiredText('  ', maxLength: 5), 'Completa este campo');
    expect(AdminCatalogValidators.requiredText('Los Pinos', maxLength: 5), 'Usa hasta 5 caracteres');
    expect(AdminCatalogValidators.requiredText(' Pinos ', maxLength: 5), isNull);
  });

  test('reads decimals with a point and checks their range', () {
    expect(AdminCatalogValidators.decimal('1,5'), 'Ingresa un número con punto decimal, por ejemplo 12.5');
    expect(AdminCatalogValidators.decimal('0', positive: true), 'Debe ser mayor que cero');
    expect(AdminCatalogValidators.percentage('120'), 'Debe estar entre 0 y 100');
    expect(AdminCatalogValidators.decimal('', required: false), isNull);
    expect(AdminCatalogValidators.percentage('12.5'), isNull);
  });

  test('takes the position of a project only with both coordinates', () {
    expect(AdminCatalogValidators.latitude('', longitude: '-76.9'), 'Ingresa también la latitud');
    expect(AdminCatalogValidators.longitude('', latitude: '-12.2'), 'Ingresa también la longitud');
    expect(AdminCatalogValidators.longitude('-200', latitude: '-12.2'), 'Debe estar entre -180 y 180');
    expect(AdminCatalogValidators.latitude('', longitude: ''), isNull);
    expect(AdminCatalogValidators.latitude('-12.2', longitude: '-76.9'), isNull);
  });

  test('takes a whole number of months up to 360', () {
    expect(AdminCatalogValidators.months('0'), 'Ingresa un número entero de meses entre 1 y 360');
    expect(AdminCatalogValidators.months('12.5'), 'Ingresa un número entero de meses entre 1 y 360');
    expect(AdminCatalogValidators.months('360'), isNull);
  });

  test('splits the stages by commas and rejects repeated ones', () {
    expect(AdminCatalogValidators.parseStages(' Norte, Sur ,, '), ['Norte', 'Sur']);
    expect(AdminCatalogValidators.stages(' , '), 'Escribe al menos una etapa, por ejemplo: Norte, Sur');
    expect(AdminCatalogValidators.stages('Norte, norte'), 'La etapa «norte» está repetida');
    expect(AdminCatalogValidators.stages('Norte, ${'x' * 81}'), 'La etapa «${'x' * 81}» supera los 80 caracteres');
  });

  test('reads prices as the app shows them', () {
    expect(AdminCatalogValidators.price('45,000.50'), isNull);
    expect(AdminCatalogValidators.price('S/ 45000'), isNull);
    expect(AdminCatalogValidators.price('45.000,50'), 'Ingresa el precio en soles, por ejemplo 45000 o 45,000.50');
    expect(AdminCatalogValidators.price('0'), 'Ingresa el precio en soles, por ejemplo 45000 o 45,000.50');
  });

  test('asks for a numeric project ID', () {
    expect(AdminCatalogValidators.projectId('abc'), 'Ingresa el ID numérico del proyecto, por ejemplo 12');
    expect(AdminCatalogValidators.projectId('0'), 'Ingresa el ID numérico del proyecto, por ejemplo 12');
    expect(AdminCatalogValidators.parseProjectId(' 12 '), 12);
  });

  test('reads one longitude,latitude vertex per line', () {
    final boundary = AdminCatalogValidators.parseBoundary('-77.0,-12.0\n\n -77.1, -12.0 \n-77.1,-12.1\n-77.0,-12.0');

    expect(boundary!.vertices, [
      (longitude: -77.0, latitude: -12.0),
      (longitude: -77.1, latitude: -12.0),
      (longitude: -77.1, latitude: -12.1),
    ]);
  });

  test('names the line of the boundary to correct', () {
    expect(
      AdminCatalogValidators.boundary('-77.0,-12.0\n-77.1 -12.0\n-77.1,-12.1'),
      'La línea 2 debe ser longitud,latitud, por ejemplo -77.0428,-12.0464',
    );
    expect(
      AdminCatalogValidators.boundary('-77.0,-12.0\n-77.1,-12.0\n-12.1,-77.1\n-200,-12.1'),
      'La línea 4 está fuera de rango: la longitud va de -180 a 180 y la latitud de -90 a 90',
    );
  });

  test('does not count the vertex that only closes the boundary', () {
    expect(
      AdminCatalogValidators.boundary('-77.0,-12.0\n-77.1,-12.0\n-77.0,-12.0'),
      'Ingresa al menos 3 vértices, uno por línea',
    );
    expect(AdminCatalogValidators.parseBoundary(''), isNull);
  });
}
