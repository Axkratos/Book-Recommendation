import { useState } from 'react';
import { BookOpen, BookMarked, Clock, Filter } from 'lucide-react';
import { useBooks } from '../context/BookContext';
import BookCard from '../components/book/BookCard';

const MyShelf = () => {
  const [activeTab, setActiveTab] = useState('to-read');
  const { myBooks, books } = useBooks();
  
  const toReadBooks = myBooks.filter(book => !book.progress || book.progress < 5);
  const favoriteBooks = myBooks.filter(book => book.rating >= 4);
  // Use the same books for history tab in this demo
  const historyBooks = books.slice(0, 4);
  
  const displayBooks = activeTab === 'to-read' 
    ? toReadBooks 
    : activeTab === 'favorites'
    ? favoriteBooks
    : historyBooks;
  
  return (
    <div className="fadeIn max-w-7xl mx-auto px-4 py-8">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-serif font-bold">My Shelf</h1>
        
        <button className="btn btn-secondary flex items-center">
          <Filter className="h-4 w-4 mr-2" />
          Filter
        </button>
      </div>
      
      <div className="mb-8">
        <div className="border-b border-gray-200">
          <nav className="flex -mb-px">
            <button
              onClick={() => setActiveTab('to-read')}
              className={`py-4 px-6 flex items-center font-medium text-sm border-b-2 ${
                activeTab === 'to-read'
                  ? 'border-primary-500 text-primary-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              <BookOpen className="h-4 w-4 mr-2" />
              To Read
            </button>
            
            <button
              onClick={() => setActiveTab('favorites')}
              className={`py-4 px-6 flex items-center font-medium text-sm border-b-2 ${
                activeTab === 'favorites'
                  ? 'border-primary-500 text-primary-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              <BookMarked className="h-4 w-4 mr-2" />
              Favorites
            </button>
            
            <button
              onClick={() => setActiveTab('history')}
              className={`py-4 px-6 flex items-center font-medium text-sm border-b-2 ${
                activeTab === 'history'
                  ? 'border-primary-500 text-primary-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              <Clock className="h-4 w-4 mr-2" />
              History
            </button>
          </nav>
        </div>
      </div>
      
      {displayBooks.length > 0 ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6">
          {displayBooks.map((book) => (
            <BookCard key={book.id} book={book} showAdd={false} />
          ))}
        </div>
      ) : (
        <div className="text-center py-12">
          <BookOpen className="h-12 w-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">No books yet</h3>
          <p className="text-gray-600">
            {activeTab === 'to-read'
              ? "You haven't added any books to your reading list yet."
              : activeTab === 'favorites'
              ? "You haven't marked any books as favorites yet."
              : "You haven't finished reading any books yet."}
          </p>
        </div>
      )}
    </div>
  );
};

export default MyShelf;