/// A vertex of a lot boundary, in WGS84 degrees.
typedef Vertex = ({double longitude, double latitude});

/// The boundary of a lot (US-52): a polygon of at least three vertices.
class LotBoundary {
  static const int minVertices = 3;

  /// The vertices in order, without repeating the first one at the end.
  final List<Vertex> vertices;

  /// Takes the vertices of an open or an already closed polygon.
  LotBoundary(List<Vertex> vertices) : vertices = List.unmodifiable(_open(vertices)) {
    if (this.vertices.length < minVertices) {
      throw ArgumentError.value(vertices, 'vertices', 'A lot boundary needs at least $minVertices vertices');
    }
  }

  static List<Vertex> _open(List<Vertex> vertices) {
    if (vertices.length > 1 && vertices.first == vertices.last) {
      return vertices.sublist(0, vertices.length - 1);
    }
    return vertices;
  }

  /// The closed ring GeoJSON expects: the vertices with the first one repeated at the end.
  List<Vertex> get ring => [...vertices, vertices.first];
}
