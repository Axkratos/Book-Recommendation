import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Play, RefreshCcw, BookOpen, Map, BookMarked, Users, Sun } from 'lucide-react';
import BookCarousel from '../components/book/BookCarousel';
import { useUser } from '../context/UserContext';
import { useBooks } from '../context/BookContext';

const Dashboard = () => {
  const { user } = useUser();
  const { books, myBooks, recommendations, getRecommendations } = useBooks();
  const [newRecommendations, setNewRecommendations] = useState(recommendations);
  
  const currentBook = myBooks.length > 0 ? myBooks[0] : null;
  
  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  };
  
  const handleNewRecommendations = () => {
    setNewRecommendations(getRecommendations(3));
  };
  
  return (
    <div className="fadeIn max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Hero Section */}
      <section className="mb-12">
        <div className="bg-gradient-to-r from-primary-50 to-accent-50 rounded-2xl p-6 md:p-8">
          <div className="md:flex md:items-center md:justify-between">
            <div className="md:w-2/3">
              <h1 className="text-3xl font-serif font-bold">
                {getGreeting()}, {user?.name}!
              </h1>
              
              <div className="mt-4 flex items-center">
                <div className="bg-primary-100 text-primary-800 py-1 px-3 rounded-full flex items-center">
                  <span className="mr-1">📚</span>
                  <span className="font-medium">{user?.readingStreak}-day streak</span>
                </div>
              </div>
              
              {currentBook && (
                <div className="mt-6 bg-white rounded-lg shadow-md p-4 md:p-6">
                  <div className="flex items-start">
                    <div className="flex-shrink-0 h-20 w-14 bg-gray-200 rounded overflow-hidden">
                      <img
                        src={currentBook.coverUrl}
                        alt={currentBook.title}
                        className="h-full w-full object-cover"
                      />
                    </div>
                    <div className="ml-4 flex-1">
                      <h3 className="font-medium">{currentBook.title}</h3>
                      <p className="text-sm text-gray-600">{currentBook.author}</p>
                      {currentBook.currentChapter && currentBook.totalChapters && (
                        <p className="text-sm mt-1">
                          Chapter {currentBook.currentChapter} of {currentBook.totalChapters}
                        </p>
                      )}
                      
                      <div className="mt-3 flex space-x-3">
                        <Link
                          to={`/reading/${currentBook.id}`}
                          className="btn-primary btn-sm flex items-center"
                        >
                          <Play className="h-3.5 w-3.5 mr-1" />
                          Resume
                        </Link>
                        <button
                          onClick={handleNewRecommendations}
                          className="btn-secondary btn-sm flex items-center"
                        >
                          <RefreshCcw className="h-3.5 w-3.5 mr-1" />
                          New Pick
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              )}
            </div>
            
            <div className="hidden md:block md:w-1/3 md:ml-8">
              <img
                src="https://images.pexels.com/photos/306534/pexels-photo-306534.jpeg?auto=compress&cs=tinysrgb&w=500"
                alt="Books"
                className="rounded-lg shadow-md max-h-48 ml-auto"
              />
            </div>
          </div>
        </div>
      </section>
      
      {/* Daily Recommendations Carousel */}
      <section className="mb-12">
        <BookCarousel
          title="Daily Recommendations"
          books={newRecommendations}
          showEmoji={true}
        />
      </section>
      
      {/* Mood & Context Snapshot */}
      <section className="mb-12 bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-medium">Mood & Context</h2>
          <button className="text-primary-600 text-sm font-medium">Update</button>
        </div>
        
        <div className="flex flex-col md:flex-row md:items-center">
          <div className="mb-4 md:mb-0 md:mr-8">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Yesterday's mood
            </label>
            <div className="inline-block bg-primary-100 text-primary-800 py-1.5 px-3 rounded-full">
              <span className="mr-1">✨</span>
              <span>Adventurous</span>
            </div>
          </div>
          
          <div className="flex-1">
            <div className="bg-blue-50 rounded-lg p-4 flex items-center">
              <Sun className="h-5 w-5 text-blue-500 mr-2" />
              <p className="text-blue-800">
                It's sunny in Kathmandu ☀️—how about a beach read?
              </p>
            </div>
          </div>
        </div>
      </section>
      
      {/* Fast-Access Tiles */}
      <section>
        <h2 className="text-xl font-medium mb-4">Quick Access</h2>
        
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <Link
            to="/reading/1"
            className="bg-white rounded-lg shadow-sm p-6 hover:shadow-md transition-shadow flex flex-col items-center text-center"
          >
            <div className="bg-purple-100 rounded-full p-3 mb-3">
              <BookOpen className="h-6 w-6 text-purple-600" />
            </div>
            <h3 className="font-medium">AI Companion</h3>
            <p className="text-sm text-gray-600 mt-1">Chat about books</p>
          </Link>
          
          <Link
            to="/universe-map"
            className="bg-white rounded-lg shadow-sm p-6 hover:shadow-md transition-shadow flex flex-col items-center text-center"
          >
            <div className="bg-blue-100 rounded-full p-3 mb-3">
              <Map className="h-6 w-6 text-blue-600" />
            </div>
            <h3 className="font-medium">Book Universe</h3>
            <p className="text-sm text-gray-600 mt-1">Explore connections</p>
          </Link>
          
          <Link
            to="/my-shelf"
            className="bg-white rounded-lg shadow-sm p-6 hover:shadow-md transition-shadow flex flex-col items-center text-center"
          >
            <div className="bg-green-100 rounded-full p-3 mb-3">
              <BookMarked className="h-6 w-6 text-green-600" />
            </div>
            <h3 className="font-medium">My Shelf</h3>
            <p className="text-sm text-gray-600 mt-1">Your collection</p>
          </Link>
          
          <Link
            to="/community"
            className="bg-white rounded-lg shadow-sm p-6 hover:shadow-md transition-shadow flex flex-col items-center text-center"
          >
            <div className="bg-accent-100 rounded-full p-3 mb-3">
              <Users className="h-6 w-6 text-accent-600" />
            </div>
            <h3 className="font-medium">Book Clubs</h3>
            <p className="text-sm text-gray-600 mt-1">Join discussions</p>
          </Link>
        </div>
      </section>
    </div>
  );
};

export default Dashboard;