import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';
import 'package:genkit_shelf/genkit_shelf.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:backend/src/flows.dart';

void main() async {
  final ai = Genkit(plugins: [googleAI()]);

  final generateLessonFlow = getGenerateLessonFlow(ai);
  final cartoonifyFlow = getCartoonifyFlow(ai);
  final illustrateFlow = getIllustrateFlow(ai);
  final storifyFlow = getStorifyFlow(ai);

  final router = Router();
  router.post('/api/generateLesson', shelfHandler(generateLessonFlow));
  router.post('/api/cartoonify', shelfHandler(cartoonifyFlow));
  router.post('/api/illustrate', shelfHandler(illustrateFlow));
  router.post('/api/storify', shelfHandler(storifyFlow));

  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final server = await io.serve(handler, '127.0.0.1', 8080);
  print('Server listening on port ${server.port}');
}
