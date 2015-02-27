library diagram_server;

import 'dart:convert';
import 'dart:io';
import 'package:shelf_bind/shelf_bind.dart';
import 'package:shelf_route/shelf_route.dart';

part 'src/entity/diagram_metadata.dart';
part 'src/resource/diagram_metadata_resource.dart';
part 'src/store/diagram_metadata_store.dart';

class CustomRouteCreator extends Routeable {
  final DiagramMetadataResource _res;
  CustomRouteCreator(this._res);
  @override
  void createRoutes(Router router) {
    router
        ..get('/search{?query}', bind(_res.search))
        ..get('/find/{id}', bind(_res.find))
        ..get('/delete/{id}', bind(_res.delete))
        ..post('/create',
            bind((@RequestBody() DiagramMetadata dm) => _res.create(dm)))
        ..post('/update',
            bind((@RequestBody() DiagramMetadata dm) => _res.update(dm)));
  }
}
