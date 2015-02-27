part of diagram_server;

/// Diagram metadata.
class DiagramMetadata {
  String id;
  String name;
  String url;
  List<String> attributes;

  DiagramMetadata();
  
  DiagramMetadata.fromJson(Map json)
      : this.id = json['id'],
        this.name = json['name'],
        this.url = json['url'],
        this.attributes = json['attributes'];

  Map toJson() => {
    'id': id,
    'name': name,
    'url': url,
    'attributes': attributes
  };
}
