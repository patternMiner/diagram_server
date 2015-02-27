// Copyright (c) 2015, Jagdish Bisa. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_bind/shelf_bind.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_exception_response/exception_response.dart';
import 'package:shelf_route/shelf_route.dart';
import 'package:diagram_server/diagram_server.dart';

void main(List<String> args) {
  var parser = new ArgParser()
      ..addOption('port', abbr: 'p', defaultsTo: '8080');
  var result = parser.parse(args);
  var port = int.parse(result['port'], onError: (val) {
    stdout.writeln('Could not parse port value "$val" into a number.');
    exit(1);
  });

  DiagramMetadataResource res = new DiagramMetadataResource(
      new DiagramMetadataStore.fromFile(new File('bin/diagram_metadata.json')));

  var rootRouter = router()..addAll(new CustomRouteCreator(res));
  var handler = const shelf.Pipeline()
      .addMiddleware(exceptionResponse())
      .addMiddleware(shelf.logRequests())
      .addHandler(rootRouter.handler);

  io.serve(handler, 'localhost', port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
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