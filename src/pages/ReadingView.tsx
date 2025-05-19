import { useParams } from 'react-router-dom';
import { useState } from 'react';
import { BookOpen, ChevronLeft, ChevronRight, Settings } from 'lucide-react';
import { useBooks } from '../context/BookContext';
import AIChatPanel from '../components/ai/AIChatPanel';

const ReadingView = () => {
  const { bookId } = useParams<{ bookId: string }>();
  const { getBookById } = useBooks();
  const [fontSize, setFontSize] = useState('medium');
  const [showSettings, setShowSettings] = useState(false);
  
  const book = getBookById(bookId || '');
  
  if (!book) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-12 text-center">
        <h2 className="text-2xl font-medium mb-4">Book not found</h2>
        <p>Sorry, we couldn't find the book you're looking for.</p>
      </div>
    );
  }
  
  // Sample chapter text
  const chapterText = `
    <h2>Chapter ${book.currentChapter || 1}</h2>
    <p>The morning sun filtered through the dense canopy, casting dappled shadows on the forest floor. ${book.title} was not what anyone would call a traditional story, but then again, tradition had long since been abandoned in this world.</p>
    <p>"We need to keep moving," said the guide, her voice barely above a whisper. "They'll be following the river, and we need to stay ahead."</p>
    <p>The protagonist nodded, adjusting the worn pack on their shoulders. Three days they'd been traveling, and already the journey had taken its toll. But there was no turning back now—not with what they carried.</p>
    <p>"How much farther to the sanctuary?" they asked, scanning the horizon where the mountains rose like sentinels against the pale sky.</p>
    <p>"Another day, maybe two if we're careful," came the reply. "But being careful might not be an option anymore."</p>
    <p>A sound in the distance—metal against stone—sent birds scattering from nearby trees. They exchanged glances, no words needed to communicate their shared fear.</p>
    <p>"They're closer than I thought," the guide muttered, her expression grim. "We need to leave the path. Now."</p>
    <p>The detour would cost them time they didn't have, but the alternative was unthinkable. As they pushed deeper into the undergrowth, the protagonist couldn't help but wonder about the choices that had led them here, and whether the price of knowledge was worth the cost they now paid.</p>
  `;
  
  const fontSizeClasses = {
    small: 'text-sm',
    medium: 'text-base',
    large: 'text-lg',
    xlarge: 'text-xl',
  };
  
  return (
    <div className="flex flex-col md:flex-row min-h-screen bg-gray-50">
      {/* Reading Panel */}
      <div className="flex-grow p-4 md:p-8">
        <div className="max-w-3xl mx-auto">
          <div className="flex justify-between items-center mb-6">
            <h1 className="text-2xl font-serif font-bold">{book.title}</h1>
            
            <div className="flex items-center space-x-2">
              <button
                onClick={() => setShowSettings(!showSettings)}
                className="p-2 rounded-full hover:bg-gray-100"
              >
                <Settings className="h-5 w-5 text-gray-600" />
              </button>
            </div>
          </div>
          
          {showSettings && (
            <div className="bg-white rounded-lg shadow-sm p-4 mb-6">
              <div className="flex items-center justify-between">
                <span className="text-sm font-medium">Font Size</span>
                <div className="flex space-x-2">
                  <button
                    onClick={() => setFontSize('small')}
                    className={`p-1 rounded ${fontSize === 'small' ? 'bg-primary-100 text-primary-800' : 'text-gray-500'}`}
                  >
                    A-
                  </button>
                  <button
                    onClick={() => setFontSize('medium')}
                    className={`p-1 rounded ${fontSize === 'medium' ? 'bg-primary-100 text-primary-800' : 'text-gray-500'}`}
                  >
                    A
                  </button>
                  <button
                    onClick={() => setFontSize('large')}
                    className={`p-1 rounded ${fontSize === 'large' ? 'bg-primary-100 text-primary-800' : 'text-gray-500'}`}
                  >
                    A+
                  </button>
                  <button
                    onClick={() => setFontSize('xlarge')}
                    className={`p-1 rounded ${fontSize === 'xlarge' ? 'bg-primary-100 text-primary-800' : 'text-gray-500'}`}
                  >
                    A++
                  </button>
                </div>
              </div>
            </div>
          )}
          
          <div className={`bg-white rounded-lg shadow-md p-6 md:p-10 ${fontSizeClasses[fontSize as keyof typeof fontSizeClasses]}`}>
            <div className="prose prose-sm md:prose-base lg:prose-lg max-w-none">
              <div dangerouslySetInnerHTML={{ __html: chapterText }} />
            </div>
          </div>
          
          <div className="flex justify-between mt-6">
            <button className="btn btn-secondary flex items-center">
              <ChevronLeft className="h-4 w-4 mr-1" />
              Previous Chapter
            </button>
            <button className="btn btn-primary flex items-center">
              Next Chapter
              <ChevronRight className="h-4 w-4 ml-1" />
            </button>
          </div>
        </div>
      </div>
      
      {/* AI Chat Sidebar */}
      <div className="w-full md:w-96 border-t md:border-t-0 md:border-l border-gray-200 bg-gray-50">
        <div className="h-full md:h-screen md:sticky md:top-0 p-4">
          <AIChatPanel bookId={bookId} />
        </div>
      </div>
    </div>
  );
};

export default ReadingView;