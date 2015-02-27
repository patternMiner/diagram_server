part of diagram_server;

/// Diagram metadata resource.
class DiagramMetadataResource {
  final DiagramMetadataStore _store;

  DiagramMetadataResource(this._store);

  DiagramMetadata create(DiagramMetadata dm) => _store.create(dm);

  DiagramMetadata update(DiagramMetadata dm) => _store.update(dm);

  DiagramMetadata find(String id) => _store.find(id);

  List<DiagramMetadata> search(String query) => _store.search(query);

  DiagramMetadata delete(String id) => _store.delete(id);
}
