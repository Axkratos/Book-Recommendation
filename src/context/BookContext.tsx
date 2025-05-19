import { createContext, useContext, useState, ReactNode } from 'react';
import { Book, books as mockBooks } from '../data/mockData';

interface BookContextType {
  books: Book[];
  recommendations: Book[];
  myBooks: Book[];
  getBookById: (id: string) => Book | undefined;
  addToMyBooks: (book: Book) => void;
  removeFromMyBooks: (bookId: string) => void;
  getRecommendations: (count?: number) => Book[];
}

const BookContext = createContext<BookContextType | undefined>(undefined);

export const useBooks = () => {
  const context = useContext(BookContext);
  if (context === undefined) {
    throw new Error('useBooks must be used within a BookProvider');
  }
  return context;
};

export const BookProvider = ({ children }: { children: ReactNode }) => {
  const [books] = useState<Book[]>(mockBooks);
  const [myBooks, setMyBooks] = useState<Book[]>([mockBooks[0], mockBooks[3]]);

  const getBookById = (id: string) => {
    return books.find(book => book.id === id);
  };

  const addToMyBooks = (book: Book) => {
    if (!myBooks.some(myBook => myBook.id === book.id)) {
      setMyBooks([...myBooks, book]);
    }
  };

  const removeFromMyBooks = (bookId: string) => {
    setMyBooks(myBooks.filter(book => book.id !== bookId));
  };

  const getRecommendations = (count = 3) => {
    // In a real app, this would use an algorithm based on user preferences
    // For now, we'll just return random books that aren't in myBooks
    const availableBooks = books.filter(
      book => !myBooks.some(myBook => myBook.id === book.id)
    );
    const shuffled = [...availableBooks].sort(() => 0.5 - Math.random());
    return shuffled.slice(0, count);
  };

  return (
    <BookContext.Provider
      value={{
        books,
        myBooks,
        recommendations: getRecommendations(),
        getBookById,
        addToMyBooks,
        removeFromMyBooks,
        getRecommendations,
      }}
    >
      {children}
    </BookContext.Provider>
  );
};