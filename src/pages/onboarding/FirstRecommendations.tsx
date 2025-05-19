import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { BookOpen, Info } from 'lucide-react';
import { books } from '../../data/mockData';
import OnboardingStep from '../../components/ui/OnboardingStep';
import BookPreviewModal from '../../components/book/BookPreviewModal';
import { useBooks } from '../../context/BookContext';

const FirstRecommendations = () => {
  const [selectedBook, setSelectedBook] = useState<null | typeof books[0]>(null);
  const { addToMyBooks } = useBooks();
  const navigate = useNavigate();
  
  // Get 5 random books for recommendations
  const recommendedBooks = books.slice(0, 5);
  
  const handlePreview = (book: typeof books[0]) => {
    setSelectedBook(book);
  };
  
  const handleFinish = () => {
    localStorage.setItem('visitedBefore', 'true');
    navigate('/dashboard');
  };
  
  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <OnboardingStep
        title="Your First Recommendations"
        currentStep={4}
        totalSteps={4}
        onNext={handleFinish}
        nextLabel="Go to Dashboard"
        onBack={() => navigate('/onboarding/sample-input')}
      >
        <div className="mb-6 flex items-start bg-blue-50 p-4 rounded-lg border border-blue-200">
          <div className="flex-shrink-0">
            <Info className="h-5 w-5 text-blue-500" />
          </div>
          <div className="ml-3">
            <h3 className="text-sm text-blue-800 font-medium">Welcome to your personalized recommendations</h3>
            <p className="mt-1 text-sm text-blue-700">
              Based on your preferences, we've selected these books for you. Click "Preview" to learn more about each one.
            </p>
          </div>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {recommendedBooks.map((book) => (
            <div key={book.id} className="book-card overflow-hidden flex flex-col h-full">
              <div className="book-cover aspect-[2/3] relative">
                <img
                  src={book.coverUrl}
                  alt={book.title}
                  className="absolute inset-0 w-full h-full object-cover"
                />
                
                <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/60 to-transparent p-3">
                  <div className="flex gap-1 flex-wrap">
                    {book.tags.slice(0, 2).map(tag => (
                      <span key={tag} className="mood-tag text-xs">
                        {tag}
                      </span>
                    ))}
                  </div>
                </div>
              </div>
              
              <div className="p-4 flex-grow flex flex-col">
                <h3 className="font-medium text-gray-900">{book.title}</h3>
                <p className="text-sm text-gray-600">{book.author}</p>
                
                <div className="mt-auto pt-4">
                  <button
                    onClick={() => handlePreview(book)}
                    className="w-full btn btn-primary flex items-center justify-center"
                  >
                    <BookOpen className="h-4 w-4 mr-2" />
                    Preview
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
        
        <div className="mt-8 text-center">
          <p className="text-gray-600">
            Don't worry! You can always explore more books and refine your preferences later.
          </p>
        </div>
      </OnboardingStep>
      
      {selectedBook && (
        <BookPreviewModal
          book={selectedBook}
          onClose={() => setSelectedBook(null)}
        />
      )}
    </div>
  );
};

export default FirstRecommendations;