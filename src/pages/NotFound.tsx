import { Link } from 'react-router-dom';
import { BookX } from 'lucide-react';

const NotFound = () => {
  return (
    <div className="min-h-[70vh] flex flex-col items-center justify-center px-4 py-12">
      <BookX className="h-20 w-20 text-gray-400 mb-6" />
      <h1 className="text-3xl font-serif font-bold text-gray-900 mb-2">Page Not Found</h1>
      <p className="text-gray-600 mb-8 text-center max-w-md">
        Sorry, we couldn't find the page you're looking for. It might have been moved, deleted, or never existed.
      </p>
      <Link to="/" className="btn-primary">
        Return to Homepage
      </Link>
    </div>
  );
};

export default NotFound;