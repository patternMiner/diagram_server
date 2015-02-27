part of diagram_server;

/// Backing store for the diagram metadata.
class DiagramMetadataStore {
  final File _storeFile;
  final _id2EntityMap = <String, DiagramMetadata>{};
  int _lastId = 0;

  DiagramMetadataStore.fromFile(File this._storeFile) {
    Map jsonData = JSON.decode(_storeFile.readAsStringSync());
    jsonData['items'].forEach((Map dm) {
      _install(new DiagramMetadata.fromJson(dm));
    });
  }
  
  /// CREATE
  DiagramMetadata create(DiagramMetadata dm) {
    _install(dm..id = _nextId);
    _saveToFile();
    return dm;
  }
  
  /// UPDATE
  DiagramMetadata update(DiagramMetadata dm) {
    _id2EntityMap[dm.id] = dm;
    _saveToFile();
    return dm;
  }
  
  /// FIND
  DiagramMetadata find(String id) => _id2EntityMap[id];
  
  /// DELETE
  DiagramMetadata delete(String id) {
    DiagramMetadata dm = _id2EntityMap.remove(id);
    _saveToFile();
    return dm;
  }
  
  /// SEARCH
  List<DiagramMetadata> search(String query) {
    if (query == null || query.isEmpty) {
     return _id2EntityMap.values.toList();
    }
    return _id2EntityMap.values.where((DiagramMetadata dm) =>
        dm.name.contains(query) || dm.attributes.any((String att) =>
            att.contains(query))).toList();
  }
  
  void _saveToFile() =>
      _storeFile.writeAsStringSync(
          JSON.encode({'items': _id2EntityMap.values.toList()}));
  
  DiagramMetadata _install(DiagramMetadata dm) {
    int id = int.parse(dm.id);
    if (id > _lastId) {
      _lastId = id;
    }
    return update(dm);
  }
  
  String get _nextId {
    if (_lastId == null) {
      _lastId = 1;
    } else {
      _lastId += 1;
    }
    return _lastId.toString();
  }
}
