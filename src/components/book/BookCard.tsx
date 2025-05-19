import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Eye, Plus, Check } from 'lucide-react';
import { Book } from '../../data/mockData';
import BookPreviewModal from './BookPreviewModal';
import { useBooks } from '../../context/BookContext';

interface BookCardProps {
  book: Book;
  showPreview?: boolean;
  showAdd?: boolean;
}

const BookCard = ({ book, showPreview = true, showAdd = true }: BookCardProps) => {
  const [showModal, setShowModal] = useState(false);
  const { myBooks, addToMyBooks, removeFromMyBooks } = useBooks();
  
  const isInMyBooks = myBooks.some(myBook => myBook.id === book.id);
  
  const handleAddOrRemove = () => {
    if (isInMyBooks) {
      removeFromMyBooks(book.id);
    } else {
      addToMyBooks(book);
    }
  };
  
  return (
    <>
      <div className="book-card flex flex-col h-full">
        <div className="book-cover aspect-[2/3] relative">
          <img 
            src={book.coverUrl} 
            alt={book.title} 
            className="absolute inset-0 w-full h-full object-cover"
          />
          
          {book.progress !== undefined && (
            <div className="absolute bottom-0 left-0 right-0 h-1 bg-gray-200">
              <div 
                className="h-full bg-primary-500"
                style={{ width: `${book.progress}%` }}
              ></div>
            </div>
          )}
          
          <div className="absolute inset-0 bg-black bg-opacity-0 hover:bg-opacity-30 transition-opacity duration-300 flex items-center justify-center opacity-0 hover:opacity-100">
            {showPreview && (
              <button
                onClick={() => setShowModal(true)}
                className="bg-white text-gray-800 rounded-full p-2 transform hover:scale-105 transition-all"
              >
                <Eye className="h-5 w-5" />
              </button>
            )}
          </div>
        </div>
        
        <div className="p-3 flex-grow flex flex-col">
          <h3 className="font-medium text-gray-900 line-clamp-2">
            <Link to={`/reading/${book.id}`} className="hover:text-primary-600">
              {book.title}
            </Link>
          </h3>
          <p className="text-sm text-gray-600 mt-1">{book.author}</p>
          
          <div className="mt-2 flex gap-1 flex-wrap">
            {book.tags.slice(0, 2).map(tag => (
              <span key={tag} className="mood-tag">
                {tag}
              </span>
            ))}
          </div>
          
          <div className="mt-auto pt-3 flex items-center justify-between">
            <div className="flex items-center">
              <span className="text-yellow-400">★</span>
              <span className="ml-1 text-sm text-gray-700">{book.rating}</span>
            </div>
            
            {showAdd && (
              <button
                onClick={handleAddOrRemove}
                className={`p-1.5 rounded-full ${
                  isInMyBooks 
                    ? 'bg-green-100 text-green-600 hover:bg-green-200' 
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                }`}
              >
                {isInMyBooks ? (
                  <Check className="h-4 w-4" />
                ) : (
                  <Plus className="h-4 w-4" />
                )}
              </button>
            )}
          </div>
        </div>
      </div>
      
      {showModal && (
        <BookPreviewModal book={book} onClose={() => setShowModal(false)} />
      )}
    </>
  );
};

export default BookCard;