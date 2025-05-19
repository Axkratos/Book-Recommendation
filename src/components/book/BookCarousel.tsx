import { useState, useRef } from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { Book } from '../../data/mockData';
import BookCard from './BookCard';

interface BookCarouselProps {
  title: string;
  books: Book[];
  showEmoji?: boolean;
}

const BookCarousel = ({ title, books, showEmoji = false }: BookCarouselProps) => {
  const carouselRef = useRef<HTMLDivElement>(null);
  const [scrollPosition, setScrollPosition] = useState(0);
  
  const handleScroll = (direction: 'left' | 'right') => {
    if (!carouselRef.current) return;
    
    const container = carouselRef.current;
    const scrollAmount = direction === 'left' ? -300 : 300;
    const newPosition = container.scrollLeft + scrollAmount;
    
    container.scrollTo({
      left: newPosition,
      behavior: 'smooth',
    });
    
    setScrollPosition(newPosition);
  };
  
  return (
    <div className="relative">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-xl font-medium">
          {title}
          {showEmoji && <span className="ml-2">✨</span>}
        </h2>
        <div className="flex space-x-2">
          <button
            onClick={() => handleScroll('left')}
            className="p-1 rounded-full border border-gray-300 text-gray-600 hover:bg-gray-100"
            disabled={scrollPosition <= 0}
          >
            <ChevronLeft className="h-5 w-5" />
          </button>
          <button
            onClick={() => handleScroll('right')}
            className="p-1 rounded-full border border-gray-300 text-gray-600 hover:bg-gray-100"
          >
            <ChevronRight className="h-5 w-5" />
          </button>
        </div>
      </div>
      
      <div
        ref={carouselRef}
        className="flex space-x-4 overflow-x-auto pb-4 hide-scrollbar"
        onScroll={(e) => setScrollPosition(e.currentTarget.scrollLeft)}
      >
        {books.map((book) => (
          <div key={book.id} className="flex-shrink-0 w-40 md:w-48">
            <BookCard book={book} />
          </div>
        ))}
      </div>
    </div>
  );
};

export default BookCarousel;