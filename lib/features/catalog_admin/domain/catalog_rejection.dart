/// Why the catalog back-office could not create, register or publish something (US-51, US-52 and US-53).
sealed class CatalogRejection implements Exception {
  const CatalogRejection();
}

/// No project has this ID.
class ProjectNotFound extends CatalogRejection {
  final int projectId;

  const ProjectNotFound(this.projectId);
}

/// The lot no longer exists.
class LotNotFound extends CatalogRejection {
  const LotNotFound();
}

/// A project is published only once it has at least one lot.
class ProjectWithoutLots extends CatalogRejection {
  const ProjectWithoutLots();
}

/// A lot is published only after its project.
class ProjectNotPublished extends CatalogRejection {
  const ProjectNotPublished();
}

/// Another lot of the project already has this code.
class LotCodeTaken extends CatalogRejection {
  final String code;

  const LotCodeTaken(this.code);
}

/// The stage of the lot is not one of its project's.
class StageNotInProject extends CatalogRejection {
  const StageNotInProject();
}

/// Two stages of the project have the same name.
class RepeatedStages extends CatalogRejection {
  const RepeatedStages();
}

enum BoundaryProblem { selfIntersecting, outOfRange, tooFewVertices }

/// The boundary of the lot is not a valid polygon.
class InvalidLotBoundary extends CatalogRejection {
  final BoundaryProblem problem;

  const InvalidLotBoundary(this.problem);
}
