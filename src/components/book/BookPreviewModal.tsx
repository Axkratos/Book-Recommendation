import { Book } from '../../data/mockData';
import { X } from 'lucide-react';
import { useBooks } from '../../context/BookContext';

interface BookPreviewModalProps {
  book: Book;
  onClose: () => void;
}

const BookPreviewModal = ({ book, onClose }: BookPreviewModalProps) => {
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
    <div className="modal-backdrop" onClick={onClose}>
      <div 
        className="modal-content slideUp"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex justify-between items-start">
          <div className="flex items-start space-x-4">
            <div className="flex-shrink-0 h-24 w-16 bg-gray-200 rounded overflow-hidden">
              <img
                src={book.coverUrl}
                alt={book.title}
                className="h-full w-full object-cover"
              />
            </div>
            <div>
              <h2 className="text-xl font-serif font-bold">{book.title}</h2>
              <p className="text-gray-600">{book.author} • {book.publishYear}</p>
              <div className="mt-1 flex items-center">
                <span className="text-yellow-400">★</span>
                <span className="ml-1 text-gray-700">{book.rating}</span>
                <span className="mx-2">•</span>
                <span className="text-gray-600">{book.genres.join(', ')}</span>
              </div>
            </div>
          </div>
          <button onClick={onClose} className="text-gray-500 hover:text-gray-700">
            <X className="h-5 w-5" />
          </button>
        </div>
        
        <div className="mt-6">
          <h3 className="text-lg font-medium mb-2">TL;DR</h3>
          <p className="text-gray-700">
            {book.summary}
          </p>
        </div>
        
        <div className="mt-6">
          <h3 className="text-lg font-medium mb-2">Key Themes</h3>
          <ul className="list-disc list-inside space-y-1">
            {book.themes.map((theme) => (
              <li key={theme} className="text-gray-700">{theme}</li>
            ))}
          </ul>
        </div>
        
        <div className="mt-8 flex space-x-4">
          <button 
            onClick={handleAddOrRemove}
            className={`btn flex-1 ${isInMyBooks ? 'btn-secondary' : 'btn-primary'}`}
          >
            {isInMyBooks ? 'Remove from My Shelf' : 'Add to My Shelf'}
          </button>
          <button 
            onClick={onClose}
            className="btn btn-secondary flex-1"
          >
            Skip
          </button>
        </div>
      </div>
    </div>
  );
};

export default BookPreviewModal;