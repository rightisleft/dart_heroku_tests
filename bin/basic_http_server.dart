import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_route/shelf_route.dart';
import 'dart:io' show Platform;
import 'dart:async' show runZoned;
import 'package:path/path.dart' show join, dirname;
import 'package:shelf_static/shelf_static.dart';

void main() {
  var pathToBuild = join(dirname(Platform.script.toFilePath()), '..', 'build/web');
  var staticHandler = createStaticHandler(pathToBuild, defaultDocument: 'index.html');

  Router aRouter = router();
  aRouter.get('/item/{itemid}', (shelf.Request request) => new shelf.Response.ok('') );

  var handler = const shelf.Pipeline()
  .addMiddleware(shelf.logRequests())
  .addHandler(staticHandler);

  var zambia = new shelf.Cascade()
  .add(aRouter.handler)
  .add(handler)
  .handler;

  var portEnv = Platform.environment['PORT'];
  var port = portEnv == null ? 9999 : int.parse(portEnv);

  runZoned(() {
    io.serve(zambia, '0.0.0.0', port);
    print("Serving $pathToBuild on port $port");
  },
  
  onError: (e, stackTrace) => print('Top-Level-Error: $e $stackTrace'));
}