import { useMemo, useState } from "react";

const exampleQuestions = [
  "What does 'attention' mean in LLMs?",
  "Explain the basics of quantum computing.",
  "What is the significance of the p-value in statistical hypothesis testing?",
  "Describe the mechanism of CRISPR-Cas9 gene editing.",
  "What is the difference between a neural network and a deep learning model?",
  "Explain the concept of blockchain and its applications beyond cryptocurrency.",
  "What is string theory?",
  "What is the role of mitochondria in cellular metabolism?",
  "Explain the concept of Nash Equilibrium in game theory.",
  "What is the difference between general and special relativity?",
  "What is a Fourier transform and what is it used for?",
  "What is the halting problem in computer science?",
  "What is the Riemann hypothesis?",
  "Explain the concept of a topological insulator.",
  "What is the Standard Model of particle physics?",
  "What is the difference between a generative and a discriminative model in machine learning?",
  "What is the function of the hippocampus in memory formation?",
  "What is the cosmological constant problem?",
  "What is the Navier-Stokes equation and why is it important?",
  "What is the concept of emergence in complex systems?",
];

export function Welcome({
  onQuestion,
}: {
  onQuestion: (question: string) => void;
}) {
  const [question, setQuestion] = useState("");
  const randomQuestions = useMemo(() => {
    const shuffled = [...exampleQuestions].sort(() => 0.5 - Math.random());
    return shuffled.slice(0, 3);
  }, []);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (question.trim()) {
      onQuestion(question);
    }
  };

  return (
    <div className="w-full max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
      <div className="mt-12">
        <form onSubmit={handleSubmit}>
          <div className="relative">
            <input
              type="text"
              name="question"
              id="question"
              className="block w-full pl-4 pr-12 py-3 text-lg border-gray-300 rounded-full shadow-sm placeholder-gray-400 bg-white focus:ring-brand-primary focus:border-brand-primary sm:text-sm"
              placeholder="What do you want explained?"
              value={question}
              onChange={(e) => setQuestion(e.target.value)}
            />
            <div className="absolute inset-y-0 right-0 flex py-1.5 pr-1.5">
              <button
                type="submit"
                className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-full shadow-sm text-white bg-brand-primary hover:bg-brand-primary/90 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-brand-primary"
              >
                Go
              </button>
            </div>
          </div>
        </form>
      </div>

      <div className="mt-6">
        <div className="mt-4 flex flex-wrap items-center justify-center gap-2">
          {randomQuestions.map((q, i) => (
            <button
              key={i}
              type="button"
              className="bg-purple-400 overflow-hidden shadow-sm rounded-full hover:bg-brand-accent/20"
              onClick={() => setQuestion(q)}
            >
              <div className="p-2 px-4">
                <p className="text-xs font-medium  text-white">{q}</p>
              </div>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
