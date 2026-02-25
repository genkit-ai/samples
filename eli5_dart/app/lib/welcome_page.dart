import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  final Function(String) onQuestion;
  final String cartoonUserImage;
  final VoidCallback onEdit;

  const WelcomePage(
      {super.key,
      required this.onQuestion,
      required this.cartoonUserImage,
      required this.onEdit});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _questionController = TextEditingController();
  final List<String> _prebakedQuestions = [
    'Why was the 2025 hurricane season quiet, then active?',
    'What did Chang\'e-6 find on the moon\'s far side?',
    'How can a cold help your body fight COVID-19?',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: widget.onEdit,
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.cartoonUserImage),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.purple.shade300, Colors.blue.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'ELI',
                      style: TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '5',
                      style: TextStyle(
                        fontSize: 130,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 8.0,
                            color: Colors.purple.withOpacity(0.3),
                            offset: const Offset(4.0, 4.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Submit a question and get a simple explanation.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _questionController,
                decoration: InputDecoration(
                  hintText: 'What do you want explained?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_questionController.text.isNotEmpty) {
                          widget.onQuestion(_questionController.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Text('Go'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: _prebakedQuestions
                    .map(
                      (question) => ElevatedButton(
                        onPressed: () => widget.onQuestion(question),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          question,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
