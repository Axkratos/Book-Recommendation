import { useState, useEffect, useRef } from 'react';
import { ZoomIn, ZoomOut, BookOpen } from 'lucide-react';
import { useBooks } from '../context/BookContext';
import BookPreviewModal from '../components/book/BookPreviewModal';

const BookUniverseMap = () => {
  const { books } = useBooks();
  const [zoom, setZoom] = useState(1);
  const [selectedBook, setSelectedBook] = useState<null | typeof books[0]>(null);
  const canvasRef = useRef<HTMLDivElement>(null);
  
  // Simplified node positions for visualization
  const nodePositions = [
    { x: 50, y: 50 },
    { x: 200, y: 100 },
    { x: 300, y: 200 },
    { x: 150, y: 250 },
    { x: 400, y: 150 },
    { x: 350, y: 50 },
    { x: 250, y: 350 },
    { x: 450, y: 300 },
  ];
  
  // Simplified connections between books
  const connections = [
    { source: 0, target: 1 },
    { source: 1, target: 2 },
    { source: 2, target: 3 },
    { source: 0, target: 4 },
    { source: 4, target: 5 },
    { source: 3, target: 6 },
    { source: 2, target: 5 },
    { source: 5, target: 7 },
  ];
  
  const handleZoomIn = () => {
    setZoom(prev => Math.min(prev + 0.2, 2));
  };
  
  const handleZoomOut = () => {
    setZoom(prev => Math.max(prev - 0.2, 0.5));
  };
  
  const handleBookClick = (book: typeof books[0]) => {
    setSelectedBook(book);
  };
  
  return (
    <div className="fadeIn min-h-screen bg-gray-50 py-8 px-4">
      <div className="max-w-7xl mx-auto">
        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex justify-between items-center mb-6">
            <h1 className="text-2xl font-serif font-bold">Book Universe Map</h1>
            
            <div className="flex items-center space-x-2">
              <button
                onClick={handleZoomOut}
                className="p-2 bg-gray-100 rounded-full hover:bg-gray-200"
              >
                <ZoomOut className="h-5 w-5 text-gray-700" />
              </button>
              <span className="text-gray-700">{Math.round(zoom * 100)}%</span>
              <button
                onClick={handleZoomIn}
                className="p-2 bg-gray-100 rounded-full hover:bg-gray-200"
              >
                <ZoomIn className="h-5 w-5 text-gray-700" />
              </button>
            </div>
          </div>
          
          <div className="border border-gray-200 rounded-lg overflow-auto h-[600px] relative">
            <div 
              ref={canvasRef}
              className="w-full h-full"
              style={{ 
                transform: `scale(${zoom})`,
                transformOrigin: 'center center',
                transition: 'transform 0.3s ease'
              }}
            >
              {/* SVG for connections */}
              <svg className="absolute inset-0 w-full h-full pointer-events-none">
                {connections.map((conn, idx) => (
                  <line
                    key={idx}
                    x1={nodePositions[conn.source].x}
                    y1={nodePositions[conn.source].y}
                    x2={nodePositions[conn.target].x}
                    y2={nodePositions[conn.target].y}
                    stroke="#CBD5E1"
                    strokeWidth="2"
                    strokeDasharray="5,5"
                  />
                ))}
              </svg>
              
              {/* Book nodes */}
              {books.slice(0, 8).map((book, idx) => (
                <div
                  key={book.id}
                  className="absolute cursor-pointer transition-transform hover:scale-105"
                  style={{
                    left: `${nodePositions[idx].x}px`,
                    top: `${nodePositions[idx].y}px`,
                    transform: 'translate(-50%, -50%)'
                  }}
                  onClick={() => handleBookClick(book)}
                >
                  <div className="relative">
                    <div className="h-16 w-12 md:h-20 md:w-14 shadow-md rounded overflow-hidden border border-gray-200">
                      <img
                        src={book.coverUrl}
                        alt={book.title}
                        className="h-full w-full object-cover"
                      />
                    </div>
                    <div className="absolute -bottom-1 -right-1 bg-white rounded-full p-1 shadow-sm border border-gray-200">
                      <BookOpen className="h-3 w-3 text-primary-600" />
                    </div>
                  </div>
                  
                  <div className="mt-2 bg-white px-2 py-1 rounded-md shadow-sm border border-gray-200 text-center">
                    <p className="text-xs font-medium truncate max-w-[100px]">{book.title}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
          
          <div className="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="bg-gray-50 rounded-lg p-4">
              <h3 className="font-medium mb-2">Map Legend</h3>
              <div className="space-y-2 text-sm">
                <div className="flex items-center">
                  <div className="h-3 w-8 bg-blue-400 rounded mr-2"></div>
                  <span>Same Author</span>
                </div>
                <div className="flex items-center">
                  <div className="h-3 w-8 bg-green-400 rounded mr-2"></div>
                  <span>Same Genre</span>
                </div>
                <div className="flex items-center">
                  <div className="h-3 w-8 bg-purple-400 rounded mr-2"></div>
                  <span>Similar Themes</span>
                </div>
                <div className="flex items-center">
                  <div className="h-3 w-8 bg-amber-400 rounded mr-2"></div>
                  <span>Recommended Together</span>
                </div>
              </div>
            </div>
            
            <div className="md:col-span-2 bg-gray-50 rounded-lg p-4">
              <h3 className="font-medium mb-2">About This Map</h3>
              <p className="text-sm text-gray-700">
                This interactive visualization shows connections between books based on shared authors, genres, themes, and reader recommendations. Click on any book to see details and discover new connections. Zoom in/out to explore the entire universe of books.
              </p>
            </div>
          </div>
        </div>
      </div>
      
      {selectedBook && (
        <BookPreviewModal
          book={selectedBook}
          onClose={() => setSelectedBook(null)}
        />
      )}
    </div>
  );
};

export default BookUniverseMap;