import { Link } from 'react-router-dom';
import { BookOpen, BookMarked, Users, Map } from 'lucide-react';
import { books } from '../data/mockData';

const Home = () => {
  const featuredBooks = books.slice(0, 3);

  return (
    <div className="fadeIn">
      {/* Hero Section */}
      <section className="bg-gradient-to-r from-primary-100 to-accent-50 py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="md:flex md:items-center md:space-x-12">
            <div className="md:w-1/2 mb-8 md:mb-0">
              <h1 className="text-4xl font-serif font-bold mb-4 leading-tight">
                Discover books that truly speak to <span className="text-primary-600">you</span>
              </h1>
              <p className="text-lg text-gray-700 mb-6">
                BookMind uses AI to understand your unique reading preferences and recommends books that match your mood, interests, and reading style.
              </p>
              <Link to="/signup" className="btn btn-primary inline-block">
                Start Your Reading Journey
              </Link>
            </div>
            
            <div className="md:w-1/2 relative h-64 md:h-96">
              <div className="absolute animate-float top-0 left-10 shadow-xl rounded-md rotate-6">
                <img
                  src={books[0].coverUrl}
                  alt="Book Cover"
                  className="h-60 w-44 md:h-72 md:w-52 object-cover rounded-md"
                />
              </div>
              <div className="absolute animate-pulse-slow top-10 right-10 shadow-xl rounded-md -rotate-3">
                <img
                  src={books[1].coverUrl}
                  alt="Book Cover"
                  className="h-56 w-40 md:h-68 md:w-48 object-cover rounded-md"
                />
              </div>
              <div className="absolute animate-float bottom-0 right-20 shadow-xl rounded-md rotate-12">
                <img
                  src={books[2].coverUrl}
                  alt="Book Cover"
                  className="h-52 w-36 md:h-64 md:w-44 object-cover rounded-md"
                />
              </div>
            </div>
          </div>
        </div>
      </section>
      
      {/* Features */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-serif font-bold text-center mb-12">How BookMind Works</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div className="text-center">
              <div className="bg-primary-100 rounded-full h-16 w-16 flex items-center justify-center mx-auto mb-4">
                <BookOpen className="h-8 w-8 text-primary-600" />
              </div>
              <h3 className="text-xl font-medium mb-2">Personalized Recommendations</h3>
              <p className="text-gray-600">Books suggested based on your unique preferences and reading history</p>
            </div>
            
            <div className="text-center">
              <div className="bg-blue-100 rounded-full h-16 w-16 flex items-center justify-center mx-auto mb-4">
                <Map className="h-8 w-8 text-blue-600" />
              </div>
              <h3 className="text-xl font-medium mb-2">Book Universe Map</h3>
              <p className="text-gray-600">Visualize connections between books and discover new paths</p>
            </div>
            
            <div className="text-center">
              <div className="bg-green-100 rounded-full h-16 w-16 flex items-center justify-center mx-auto mb-4">
                <BookMarked className="h-8 w-8 text-green-600" />
              </div>
              <h3 className="text-xl font-medium mb-2">AI Reading Companion</h3>
              <p className="text-gray-600">Get insights, explanations, and context while you read</p>
            </div>
            
            <div className="text-center">
              <div className="bg-accent-100 rounded-full h-16 w-16 flex items-center justify-center mx-auto mb-4">
                <Users className="h-8 w-8 text-accent-600" />
              </div>
              <h3 className="text-xl font-medium mb-2">Community Clubs</h3>
              <p className="text-gray-600">Connect with readers who share your specific interests</p>
            </div>
          </div>
        </div>
      </section>
      
      {/* Featured Books */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-serif font-bold text-center mb-12">Featured Recommendations</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {featuredBooks.map((book) => (
              <div key={book.id} className="book-card p-0 overflow-hidden flex flex-col h-full">
                <div className="book-cover aspect-[2/3]">
                  <img
                    src={book.coverUrl}
                    alt={book.title}
                    className="w-full h-full object-cover"
                  />
                </div>
                <div className="p-4 flex-grow flex flex-col">
                  <h3 className="font-medium text-lg">{book.title}</h3>
                  <p className="text-gray-600">{book.author}</p>
                  <p className="mt-2 text-sm text-gray-500 line-clamp-3">{book.summary}</p>
                  <div className="mt-auto pt-4">
                    <Link to="/signup" className="btn btn-primary w-full text-center">
                      Learn More
                    </Link>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>
      
      {/* CTA */}
      <section className="py-20 bg-primary-600 text-white">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl font-serif font-bold mb-4">Ready to transform your reading experience?</h2>
          <p className="text-xl mb-8 text-primary-100">
            Join thousands of readers discovering their next favorite book.
          </p>
          <Link to="/signup" className="btn bg-white text-primary-700 hover:bg-gray-100 text-lg px-8 py-3">
            Get Started for Free
          </Link>
        </div>
      </section>
    </div>
  );
};

export default Home;