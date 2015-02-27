library mock_diagram_server;

import 'dart:async';
import 'dart:io';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_bind/shelf_bind.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_exception_response/exception_response.dart';
import 'package:shelf_route/shelf_route.dart';
import 'package:diagram_server/diagram_server.dart';

class MockDiagramServer {
  shelf.Handler _handler;
  HttpServer _server;

  MockDiagramServer() {
    DiagramMetadataResource res = new DiagramMetadataResource(
        new DiagramMetadataStore.fromFile(new File('test/diagram_metadata.json')));

    var rootRouter = router()..addAll(new CustomRouteCreator(res));
    _handler = const shelf.Pipeline()
        .addMiddleware(exceptionResponse())
        .addMiddleware(shelf.logRequests())
        .addHandler(rootRouter.handler);
  }

  Future<HttpServer> start() {
    if (_server == null) {
      return io.serve(_handler, 'localhost', 8080).then((HttpServer server) {
        _server = server;
        print('Serving at http://${server.address.host}:${server.port}');
      });
    }
    return new Future.value(_server);
  }

  Future<HttpServer> stop() {
    if (_server != null) {
      return _server.close().then((_) => _server = null);
    }
    return new Future.value(_server);
  }
}

class CustomRouteCreator extends Routeable {
  final DiagramMetadataResource _res;
  CustomRouteCreator(this._res);
  @override
  void createRoutes(Router router) {
    router
        ..get('/search{?query}',
            bind((String query) => _res.search(query)))
        ..get('/find/{id}',
            bind((String id) => _res.find(id)))
        ..get('/delete/{id}',
            bind((String id) => _res.delete(id)))
        ..post('/create',
            bind((@RequestBody() DiagramMetadata dm) => _res.create(dm)))
        ..post('/update',
            bind((@RequestBody() DiagramMetadata dm) => _res.update(dm)));
  }
}
