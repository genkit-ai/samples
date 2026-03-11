// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';

import '../lib/sequential_processing.dart';
import '../lib/conditional_routing.dart';
import '../lib/parallel_execution.dart';
import '../lib/tool_calling.dart';
import '../lib/agentic_rag.dart';
import '../lib/iterative_refinement.dart';
import '../lib/autonomous_operation.dart';
import '../lib/stateful_interactions.dart';

void main(List<String> arguments) async {
  // Initialize Genkit
  final ai = Genkit(
    plugins: [googleAI()],
    model: googleAI.gemini('gemini-2.5-flash'),
  );

  // Initialize all flows
  defineSequentialProcessingFlows(ai);
  defineConditionalRoutingFlows(ai);
  defineParallelExecutionFlows(ai);
  defineToolCallingFlows(ai);
  defineIterativeRefinementFlows(ai);
  defineAutonomousOperationFlows(ai);
  defineStatefulInteractionFlows(ai);
  defineAgenticRagFlows(ai);
}
