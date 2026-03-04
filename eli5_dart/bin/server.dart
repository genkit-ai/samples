import 'package:genkit_shelf/genkit_shelf.dart';
import 'package:eli5_dart/src/flows/cartoonify.dart';
import 'package:eli5_dart/src/flows/illustrate.dart';
import 'package:eli5_dart/src/flows/storify.dart';

void main() async {
  // Start the Genkit Flow server and register our flows
  await startFlowServer(
    flows: [
      cartoonifyFlow,
      illustrateFlow,
      storifyFlow,
    ],
    port: 3400, // Matching the implementation plan port
    cors: {'origin': '*'}, // Allow Flutter web client to connect
  );
}
