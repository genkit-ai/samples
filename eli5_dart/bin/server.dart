import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';
import 'package:genkit_shelf/genkit_shelf.dart';
import 'package:eli5_dart/src/flows/cartoonify.dart';
import 'package:eli5_dart/src/flows/illustrate.dart';
import 'package:eli5_dart/src/flows/storify.dart';

void main() async {
  final ai = Genkit(plugins: [googleAI()]);

  // Start the Genkit Flow server and register our flows
  await startFlowServer(
    flows: [
      defineCartoonifyFlow(ai),
      defineIllustrateFlow(ai),
      defineStorifyFlow(ai),
    ],
    port: 3400, // Matching the implementation plan port
    cors: {'origin': '*'}, // Allow Flutter web client to connect
  );
}
