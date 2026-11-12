import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/catalog_admin/domain/lot_boundary.dart';
import 'package:inmonode/features/catalog_admin/domain/new_project.dart';

import '../catalog_admin_fakes.dart';

void main() {
  const a = (longitude: -77.0, latitude: -12.0);
  const b = (longitude: -77.1, latitude: -12.0);
  const c = (longitude: -77.1, latitude: -12.1);

  test('closes the ring by repeating the first vertex', () {
    expect(LotBoundary(const [a, b, c]).ring, [a, b, c, a]);
  });

  test('takes a polygon that is already closed', () {
    final boundary = LotBoundary(const [a, b, c, a]);

    expect(boundary.vertices, [a, b, c]);
    expect(boundary.ring, [a, b, c, a]);
  });

  test('needs three distinct vertices', () {
    expect(() => LotBoundary(const [a, b]), throwsArgumentError);
    expect(() => LotBoundary(const [a, b, a]), throwsArgumentError);
  });

  test('a project takes its latitude and longitude together', () {
    expect(
      () => NewProject(
        name: 'Los Pinos',
        location: 'Lurín',
        latitude: -12.2,
        financingRules: testNewProject().financingRules,
        stages: const ['Norte'],
      ),
      throwsArgumentError,
    );
  });
}
