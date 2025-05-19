import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import OnboardingStep from '../../components/ui/OnboardingStep';
import { useUser } from '../../context/UserContext';

const genres = [
  { id: 'mystery', name: 'Mystery' },
  { id: 'scifi', name: 'Science Fiction' },
  { id: 'fantasy', name: 'Fantasy' },
  { id: 'romance', name: 'Romance' },
  { id: 'historical', name: 'Historical Fiction' },
  { id: 'thriller', name: 'Thriller' },
  { id: 'horror', name: 'Horror' },
  { id: 'literary', name: 'Literary Fiction' },
  { id: 'young-adult', name: 'Young Adult' },
  { id: 'biography', name: 'Biography' },
  { id: 'philosophy', name: 'Philosophy' },
  { id: 'poetry', name: 'Poetry' },
];

const authors = [
  'N.K. Jemisin',
  'Neil Gaiman',
  'Kazuo Ishiguro',
  'Toni Morrison',
  'Stephen King',
  'Octavia Butler',
  'Jane Austen',
  'Gabriel García Márquez',
  'Haruki Murakami',
  'Chimamanda Ngozi Adichie',
  'Margaret Atwood',
  'James Baldwin',
];

const OnboardingQuiz = () => {
  const [step, setStep] = useState(0);
  const [selectedGenres, setSelectedGenres] = useState<string[]>([]);
  const [selectedAuthors, setSelectedAuthors] = useState<string[]>([]);
  const [mood, setMood] = useState(50);
  
  const { updatePreferences } = useUser();
  const navigate = useNavigate();
  
  const handleGenreToggle = (genreId: string) => {
    if (selectedGenres.includes(genreId)) {
      setSelectedGenres(selectedGenres.filter(id => id !== genreId));
    } else {
      setSelectedGenres([...selectedGenres, genreId]);
    }
  };
  
  const handleAuthorToggle = (author: string) => {
    if (selectedAuthors.includes(author)) {
      setSelectedAuthors(selectedAuthors.filter(a => a !== author));
    } else {
      setSelectedAuthors([...selectedAuthors, author]);
    }
  };
  
  const handleNext = () => {
    if (step === 2) {
      // Save preferences
      updatePreferences({
        genres: selectedGenres,
        authors: selectedAuthors,
        mood: getMoodLabel(mood),
      });
      
      // Navigate to next step
      navigate('/onboarding/sample-input');
    } else {
      setStep(step + 1);
    }
  };
  
  const handleBack = () => {
    setStep(step - 1);
  };
  
  const getMoodLabel = (value: number): string => {
    if (value < 25) return 'Reflective';
    if (value < 50) return 'Balanced';
    if (value < 75) return 'Adventurous';
    return 'Thrilling';
  };
  
  const getMoodEmoji = (value: number): string => {
    if (value < 25) return '🧠';
    if (value < 50) return '📖';
    if (value < 75) return '✨';
    return '🔥';
  };
  
  return (
    <div className="min-h-screen bg-gray-50 py-12">
      {step === 0 && (
        <OnboardingStep
          title="What genres do you enjoy?"
          currentStep={1}
          totalSteps={3}
          onNext={handleNext}
          nextDisabled={selectedGenres.length === 0}
        >
          <p className="text-gray-600 mb-6">Choose at least one genre that interests you. This will help us find books you'll love.</p>
          
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
            {genres.map((genre) => (
              <button
                key={genre.id}
                onClick={() => handleGenreToggle(genre.id)}
                className={`p-3 rounded-lg border transition-colors ${
                  selectedGenres.includes(genre.id)
                    ? 'bg-primary-100 border-primary-300 text-primary-800'
                    : 'bg-white border-gray-200 text-gray-700 hover:bg-gray-50'
                }`}
              >
                {genre.name}
              </button>
            ))}
          </div>
        </OnboardingStep>
      )}
      
      {step === 1 && (
        <OnboardingStep
          title="Who are your favorite authors?"
          currentStep={2}
          totalSteps={3}
          onNext={handleNext}
          onBack={handleBack}
        >
          <p className="text-gray-600 mb-6">Select any authors whose work you've enjoyed. Don't worry if you don't recognize many names.</p>
          
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
            {authors.map((author) => (
              <button
                key={author}
                onClick={() => handleAuthorToggle(author)}
                className={`p-3 rounded-lg border transition-colors ${
                  selectedAuthors.includes(author)
                    ? 'bg-primary-100 border-primary-300 text-primary-800'
                    : 'bg-white border-gray-200 text-gray-700 hover:bg-gray-50'
                }`}
              >
                {author}
              </button>
            ))}
          </div>
        </OnboardingStep>
      )}
      
      {step === 2 && (
        <OnboardingStep
          title="What are you in the mood for?"
          currentStep={3}
          totalSteps={3}
          onNext={handleNext}
          onBack={handleBack}
          nextLabel="Finish"
        >
          <p className="text-gray-600 mb-6">Adjust the slider to indicate what kind of reading experience you're seeking right now.</p>
          
          <div className="space-y-6">
            <div className="flex justify-between text-sm text-gray-500">
              <span>Thoughtful & Reflective</span>
              <span>Exciting & Fast-paced</span>
            </div>
            
            <input
              type="range"
              min="0"
              max="100"
              value={mood}
              onChange={(e) => setMood(parseInt(e.target.value))}
              className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-primary-600"
            />
            
            <div className="text-center mt-8">
              <div className="text-4xl mb-2">{getMoodEmoji(mood)}</div>
              <div className="text-xl font-medium text-primary-700">{getMoodLabel(mood)}</div>
              <p className="text-gray-600 mt-2">
                {mood < 25 
                  ? "You're looking for books that make you think deeply and explore complex ideas."
                  : mood < 50
                  ? "You want a balance of thought-provoking content and engaging storytelling."
                  : mood < 75
                  ? "You're seeking stories that take you on an adventure with memorable characters."
                  : "You're in the mood for page-turners that keep you on the edge of your seat."
                }
              </p>
            </div>
          </div>
        </OnboardingStep>
      )}
    </div>
  );
};

export default OnboardingQuiz;