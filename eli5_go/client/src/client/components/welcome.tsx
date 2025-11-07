import { useMemo, useState, useEffect } from "react";
import { QuestionHistory } from "./question-history.js";

const exampleQuestions = [
  "Why is the interstellar visitor 3I/ATLAS so interesting?",
  "How are rising seas harming Easter Island's statues?",
  "What did Chang'e-6 find on the moon's far side?",
  "How did Webb spot Uranus's new tiny moon?",
  "What's special about the new 'carbon ring'?",
  "How can a cold help your body fight COVID-19?",
  "How will the NISAR satellite map changes on Earth?",
  "What can the new 'dome-headed' dinosaur teach us?",
  "How is climate change threatening the world's vanilla?",
  "How can sunlight break down 'forever chemicals'?",
  "How might Midkine protein help fight Alzheimer's?",
  "What does Britain's 'sail-backed' dinosaur reveal?",
  "How can we 'map' a healthy human body?",
  "Why was the 'RBFLOAT' space signal so special?",
  "How can new medicine help babies with SMA early?",
  "Why is bird flu in cows low risk to people?",
  "How does 'cell vomiting' help a cell heal?",
  "Why are prices for services staying so high?",
  "How does sickle cell gene therapy help the brain?",
  "How do 'bone-eating worms' help the deep ocean?",
  "How do digital payments create a 'digital divide'?",
  "Why was the 2025 hurricane season quiet, then active?",
  "How does port automation change jobs for people?",
  "What's new with the 'Hand of God' pulsar?",
  "Is a new planet hiding in Alpha Centauri?",
  "How did Solar Orbiter find the sun's 'fast wind' source?",
  "How do greenhouse gases harm our health?",
  "What can the oldest lizard fossil teach us?",
  "How do microbes shape a baby's brain before birth?",
  "What can weaver ants teach us about teamwork?",
];

export function Welcome({
  onQuestion,
  initialQuestion,
}: {
  onQuestion: (question: string) => void;
  initialQuestion?: string;
}) {
  const [question, setQuestion] = useState(initialQuestion || "");

  useEffect(() => {
    if (initialQuestion) {
      setQuestion(initialQuestion);
    }
  }, [initialQuestion]);
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
      <QuestionHistory />
    </div>
  );
}
