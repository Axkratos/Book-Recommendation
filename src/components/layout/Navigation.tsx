import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Search, BookOpen, BellDot, User, Menu, X, LogOut, BookMarked, Settings } from 'lucide-react';
import { useUser } from '../../context/UserContext';
import NotificationsPanel from '../ui/NotificationsPanel';

const Navigation = () => {
  const { user, isAuthenticated, logout } = useUser();
  const navigate = useNavigate();
  const [showNotifications, setShowNotifications] = useState(false);
  const [showMobileMenu, setShowMobileMenu] = useState(false);
  const [showProfileMenu, setShowProfileMenu] = useState(false);
  
  const toggleNotifications = () => {
    setShowNotifications(!showNotifications);
  };

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  return (
    <nav className="bg-white shadow-sm sticky top-0 z-30">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-16">
          <div className="flex items-center">
            <Link to="/" className="flex items-center">
              <BookOpen className="h-8 w-8 text-primary-600" />
              <span className="ml-2 text-xl font-serif font-bold">BookMind</span>
            </Link>
          </div>
          
          <div className="hidden md:flex md:items-center md:space-x-4">
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Search className="h-5 w-5 text-gray-400" />
              </div>
              <input
                type="text"
                className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-full bg-gray-50 focus:ring-primary-500 focus:border-primary-500"
                placeholder="Find a book, author or topic..."
              />
            </div>
            
            {isAuthenticated ? (
              <>
                <button
                  onClick={toggleNotifications}
                  className="p-2 rounded-full hover:bg-gray-100 relative"
                >
                  <BellDot className="h-6 w-6 text-gray-600" />
                  <span className="absolute top-1 right-1 block h-2 w-2 rounded-full bg-red-500"></span>
                </button>
                
                <div className="relative">
                  <button 
                    onClick={() => setShowProfileMenu(!showProfileMenu)}
                    className="flex items-center space-x-2 p-2 rounded-full hover:bg-gray-100"
                  >
                    <img
                      src={user?.avatar}
                      alt={user?.name}
                      className="h-8 w-8 rounded-full"
                    />
                    <span className="hidden lg:inline-block text-gray-700">{user?.name}</span>
                  </button>
                  
                  {showProfileMenu && (
                    <div className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 ring-1 ring-black ring-opacity-5">
                      <Link
                        to="/my-shelf"
                        className="flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                        onClick={() => setShowProfileMenu(false)}
                      >
                        <BookMarked className="h-4 w-4 mr-2" />
                        My Shelf
                      </Link>
                      <Link
                        to="/settings"
                        className="flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                        onClick={() => setShowProfileMenu(false)}
                      >
                        <Settings className="h-4 w-4 mr-2" />
                        Settings
                      </Link>
                      <button
                        onClick={() => {
                          handleLogout();
                          setShowProfileMenu(false);
                        }}
                        className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                      >
                        <LogOut className="h-4 w-4 mr-2" />
                        Sign Out
                      </button>
                    </div>
                  )}
                </div>
              </>
            ) : (
              <Link
                to="/signup"
                className="btn-primary"
              >
                Sign Up
              </Link>
            )}
          </div>
          
          <div className="flex md:hidden items-center">
            <button
              onClick={() => setShowMobileMenu(!showMobileMenu)}
              className="p-2 rounded-md text-gray-400"
            >
              {showMobileMenu ? (
                <X className="h-6 w-6" />
              ) : (
                <Menu className="h-6 w-6" />
              )}
            </button>
          </div>
        </div>
      </div>
      
      {/* Mobile menu */}
      {showMobileMenu && (
        <div className="md:hidden bg-white border-t border-gray-200 py-2 px-4">
          <div className="flex items-center mb-3">
            <div className="w-full relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Search className="h-5 w-5 text-gray-400" />
              </div>
              <input
                type="text"
                className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-full bg-gray-50"
                placeholder="Find a book, author or topic..."
              />
            </div>
          </div>
          
          {isAuthenticated ? (
            <div className="space-y-1">
              <Link
                to="/my-shelf"
                className="flex items-center py-2 text-base font-medium text-gray-700"
              >
                <BookMarked className="h-5 w-5 mr-2" />
                My Shelf
              </Link>
              <Link
                to="/settings"
                className="flex items-center py-2 text-base font-medium text-gray-700"
              >
                <Settings className="h-5 w-5 mr-2" />
                Settings
              </Link>
              <button
                onClick={handleLogout}
                className="flex items-center w-full py-2 text-base font-medium text-gray-700"
              >
                <LogOut className="h-5 w-5 mr-2" />
                Sign Out
              </button>
            </div>
          ) : (
            <Link
              to="/signup"
              className="block py-2 text-base font-medium text-primary-600"
            >
              Sign Up
            </Link>
          )}
        </div>
      )}
      
      {showNotifications && (
        <NotificationsPanel onClose={() => setShowNotifications(false)} />
      )}
    </nav>
  );
};

export default Navigation;