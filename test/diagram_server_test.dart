library diagram_server_test;

import 'dart:io';
import 'dart:convert';
import 'package:unittest/unittest.dart';
import 'package:diagram_server/diagram_server.dart';
import 'package:diagram_server/testing/mock_diagram_server.dart';
import 'package:unittest/vm_config.dart';

main() {
  useVMConfiguration();

  group('Diagram server', () {
    DiagramMetadata testDm = new DiagramMetadata.fromJson(const {
      "id":"1",
      "name":"blah_1",
      "url":"blah_url_1",
      "attributes": const ["tag1","tag2"]
    });
    MockDiagramServer server = new MockDiagramServer();
    HttpClient client = new HttpClient();
    setUp(() => server.start());
    tearDown(() => server.stop());

    group('API', () {

      /// SEARCH
      test("'search' results in 3 items.", () {
        client.getUrl(Uri.parse("http://localhost:8080/search?query"))
            .then((HttpClientRequest request) {
              return request.close();
            })
            .then(expectAsync((HttpClientResponse response) {
              expect(response.statusCode, 200);
              response.transform(UTF8.decoder).listen(expectAsync((contents) {
                List<Map> result = JSON.decode(contents);
                List<DiagramMetadata> diagramMetadataList =
                    result.map((Map jsonData) =>
                        new DiagramMetadata.fromJson(jsonData)).toList();
                expect(diagramMetadataList.length, 3);
              }));
            }));

      });

      /// FIND
      test("'find' returns the correct item.", () {
        client.getUrl(Uri.parse("http://localhost:8080/find/1"))
            .then((HttpClientRequest request) {
              return request.close();
            })
            .then(expectAsync((HttpClientResponse response) {
              expect(response.statusCode, 200);
              response.transform(UTF8.decoder).listen(expectAsync((contents) {
                Map result = JSON.decode(contents);
                DiagramMetadata dm = new DiagramMetadata.fromJson(result);
                expect(dm.id, testDm.id);
                expect(dm.name, testDm.name);
                expect(dm.url, testDm.url);
                expect(dm.attributes, testDm.attributes);
              }));
            }));

      });

      /// UPDATE
      test("'update' updates the correct item.", () {
        client.postUrl(Uri.parse("http://localhost:8080/update"))
            .then((HttpClientRequest request) {
          request.headers.contentType =
              new ContentType("application", "json", charset: "utf-8");
            Map jsonData = testDm.toJson();
            List attrs = jsonData['attributes'].toList();
            attrs.add('bogusTag');
            jsonData['attributes'] = attrs;
            request.write(JSON.encode(jsonData));
            return request.close();
          }).then(expectAsync((HttpClientResponse response) {
          expect(response.statusCode, 200);
          response.transform(UTF8.decoder).listen(expectAsync((contents) {
            Map result = JSON.decode(contents);
            DiagramMetadata dm = new DiagramMetadata.fromJson(result);
            expect(dm.id, '1');
            expect(dm.attributes[2], 'bogusTag');
          }));
        }));
      });

      test("'update' updates the correct item.", () {
        client.postUrl(Uri.parse("http://localhost:8080/update"))
            .then((HttpClientRequest request) {
          request.headers.contentType =
              new ContentType("application", "json", charset: "utf-8");
            request.write(JSON.encode(testDm.toJson()));
            return request.close();
          }).then(expectAsync((HttpClientResponse response) {
          expect(response.statusCode, 200);
          response.transform(UTF8.decoder).listen(expectAsync((contents) {
            Map result = JSON.decode(contents);
            DiagramMetadata dm = new DiagramMetadata.fromJson(result);
            expect(dm.id, '1');
            expect(dm.attributes, testDm.attributes);
          }));
        }));
      });

      /// CREATE
      test("'create' creates the correct item.", () {
        client.postUrl(Uri.parse("http://localhost:8080/create"))
            .then((HttpClientRequest request) {
          request.headers.contentType =
              new ContentType("application", "json", charset: "utf-8");
            Map jsonData = testDm.toJson();
            jsonData['id'] = null;
            request.write(JSON.encode(jsonData));
            return request.close();
          }).then(expectAsync((HttpClientResponse response) {
          expect(response.statusCode, 200);
          response.transform(UTF8.decoder).listen(expectAsync((contents) {
            Map result = JSON.decode(contents);
            DiagramMetadata dm = new DiagramMetadata.fromJson(result);
            expect(dm.id != testDm.id, true);
            expect(dm.name, testDm.name);
            expect(dm.url, testDm.url);
            expect(dm.attributes, testDm.attributes);
          }));
        }));
      });

      /// DELETE
      test("'delete' deletes the correct item.", () {
        client.getUrl(Uri.parse("http://localhost:8080/delete/4"))
            .then((HttpClientRequest request) {
              return request.close();
            })
            .then(expectAsync((HttpClientResponse response) {
              expect(response.statusCode, 200);
              response.transform(UTF8.decoder).listen(expectAsync((contents) {
                Map result = JSON.decode(contents);
                DiagramMetadata dm = new DiagramMetadata.fromJson(result);
                expect(dm.id != testDm.id, true);
                expect(dm.name, testDm.name);
                expect(dm.url, testDm.url);
                expect(dm.attributes, testDm.attributes);
              }));
            }));

      });
    });
  });
}