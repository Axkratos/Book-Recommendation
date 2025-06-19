import { likeBooks } from '../controllers/userController.js'; // Adjust path as needed
import User from '../models/userModel.js';

// Mock the User model
jest.mock('../models/userModel.js');

describe('likeBooks Controller', () => {
  let req, res;

  beforeEach(() => {
    // Reset mocks before each test
    jest.clearAllMocks();
    
    // Setup mock request and response objects
    req = {
      user: { id: 'user123' },
      body: { liked_books: ['Book 1', 'Book 2'] }
    };
    
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
  });

  describe('Successful cases', () => {
    test('should successfully add liked books to user', async () => {
      // Mock successful user update
      const mockUser = {
        _id: 'user123',
        liked_books: ['Book 1', 'Book 2', 'Existing Book']
      };
      
      User.findByIdAndUpdate.mockResolvedValue(mockUser);

      await likeBooks(req, res);

      expect(User.findByIdAndUpdate).toHaveBeenCalledWith(
        'user123',
        { $addToSet: { liked_books: { $each: ['Book 1', 'Book 2'] } } },
        { new: true }
      );
      
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        status: 'success',
        data: {
          liked_books: ['Book 1', 'Book 2', 'Existing Book']
        }
      });
    });

    test('should handle empty liked_books array', async () => {
      req.body.liked_books = [];
      
      const mockUser = {
        _id: 'user123',
        liked_books: ['Existing Book']
      };
      
      User.findByIdAndUpdate.mockResolvedValue(mockUser);

      await likeBooks(req, res);

      expect(User.findByIdAndUpdate).toHaveBeenCalledWith(
        'user123',
        { $addToSet: { liked_books: { $each: [] } } },
        { new: true }
      );
      
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        status: 'success',
        data: {
          liked_books: ['Existing Book']
        }
      });
    });

    test('should handle single book in array', async () => {
      req.body.liked_books = ['Single Book'];
      
      const mockUser = {
        _id: 'user123',
        liked_books: ['Single Book']
      };
      
      User.findByIdAndUpdate.mockResolvedValue(mockUser);

      await likeBooks(req, res);

      expect(User.findByIdAndUpdate).toHaveBeenCalledWith(
        'user123',
        { $addToSet: { liked_books: { $each: ['Single Book'] } } },
        { new: true }
      );
      
      expect(res.status).toHaveBeenCalledWith(200);
    });
  });

  describe('Validation errors', () => {
    test('should return 400 if liked_books is not an array', async () => {
      req.body.liked_books = 'not an array';

      await likeBooks(req, res);

      expect(User.findByIdAndUpdate).not.toHaveBeenCalled();
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        status: 'fail',
        message: 'liked_books must be an array of strings.'
      });
    });

    test('should return 400 if liked_books is null', async () => {
      req.body.liked_books = null;

      await likeBooks(req, res);

      expect(User.findByIdAndUpdate).not.toHaveBeenCalled();
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        status: 'fail',
        message: 'liked_books must be an array of strings.'
      });
    });

    test('should return 400 if liked_books is undefined', async () => {
      req.body = {}; // liked_books is undefined

      await likeBooks(req, res);

      expect(User.findByIdAndUpdate).not.toHaveBeenCalled();
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        status: 'fail',
        message: 'liked_books must be an array of strings.'
      });
    });

    test('should return 400 if liked_books is a number', async () => {
      req.body.liked_books = 123;

      await likeBooks(req, res);

      expect(User.findByIdAndUpdate).not.toHaveBeenCalled();
      expect(res.status).toHaveBeenCalledWith(400);
    });

    test('should return 400 if liked_books is an object', async () => {
      req.body.liked_books = { book: 'Book 1' };

      await likeBooks(req, res);

      expect(User.findByIdAndUpdate).not.toHaveBeenCalled();
      expect(res.status).toHaveBeenCalledWith(400);
    });
  });

  describe('User not found', () => {
    test('should return 404 if user is not found', async () => {
      User.findByIdAndUpdate.mockResolvedValue(null);

      await likeBooks(req, res);

      expect(User.findByIdAndUpdate).toHaveBeenCalledWith(
        'user123',
        { $addToSet: { liked_books: { $each: ['Book 1', 'Book 2'] } } },
        { new: true }
      );
      
      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({
        status: 'fail',
        message: 'User not found.'
      });
    });
  });

  describe('Database errors', () => {
    test('should return 500 if database operation fails', async () => {
      const dbError = new Error('Database connection failed');
      User.findByIdAndUpdate.mockRejectedValue(dbError);

      await likeBooks(req, res);

      expect(User.findByIdAndUpdate).toHaveBeenCalledWith(
        'user123',
        { $addToSet: { liked_books: { $each: ['Book 1', 'Book 2'] } } },
        { new: true }
      );
      
      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({
        status: 'error',
        message: 'Database connection failed'
      });
    });

    test('should handle MongoDB validation error', async () => {
      const validationError = new Error('Validation failed');
      validationError.name = 'ValidationError';
      User.findByIdAndUpdate.mockRejectedValue(validationError);

      await likeBooks(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({
        status: 'error',
        message: 'Validation failed'
      });
    });

    test('should handle MongoDB cast error', async () => {
      const castError = new Error('Cast to ObjectId failed');
      castError.name = 'CastError';
      User.findByIdAndUpdate.mockRejectedValue(castError);

      await likeBooks(req, res);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({
        status: 'error',
        message: 'Cast to ObjectId failed'
      });
    });
  });

  describe('Edge cases', () => {
    test('should handle very long book titles', async () => {
      const longBookTitle = 'A'.repeat(1000);
      req.body.liked_books = [longBookTitle];
      
      const mockUser = {
        _id: 'user123',
        liked_books: [longBookTitle]
      };
      
      User.findByIdAndUpdate.mockResolvedValue(mockUser);

      await likeBooks(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        status: 'success',
        data: {
          liked_books: [longBookTitle]
        }
      });
    });

    test('should handle special characters in book titles', async () => {
      req.body.liked_books = ['Book with émojis 📚', 'Book & Author', 'Book "Quotes"'];
      
      const mockUser = {
        _id: 'user123',
        liked_books: ['Book with émojis 📚', 'Book & Author', 'Book "Quotes"']
      };
      
      User.findByIdAndUpdate.mockResolvedValue(mockUser);

      await likeBooks(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
    });

    test('should handle large arrays of books', async () => {
      const manyBooks = Array.from({ length: 100 }, (_, i) => `Book ${i + 1}`);
      req.body.liked_books = manyBooks;
      
      const mockUser = {
        _id: 'user123',
        liked_books: manyBooks
      };
      
      User.findByIdAndUpdate.mockResolvedValue(mockUser);

      await likeBooks(req, res);

      expect(User.findByIdAndUpdate).toHaveBeenCalledWith(
        'user123',
        { $addToSet: { liked_books: { $each: manyBooks } } },
        { new: true }
      );
      
      expect(res.status).toHaveBeenCalledWith(200);
    });

    test('should handle array with duplicate book titles', async () => {
      req.body.liked_books = ['Book 1', 'Book 1', 'Book 2'];
      
      const mockUser = {
        _id: 'user123',
        liked_books: ['Book 1', 'Book 2'] // MongoDB $addToSet removes duplicates
      };
      
      User.findByIdAndUpdate.mockResolvedValue(mockUser);

      await likeBooks(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        status: 'success',
        data: {
          liked_books: ['Book 1', 'Book 2']
        }
      });
    });
  });

  describe('Request structure validation', () => {
    test('should handle missing req.user', async () => {
      req.user = undefined;

      // This should cause an error when trying to access req.user.id
      await expect(likeBooks(req, res)).rejects.toThrow();
    });

    test('should handle missing req.user.id', async () => {
      req.user = {}; // user object exists but no id

      await expect(likeBooks(req, res)).rejects.toThrow();
    });

    test('should handle missing req.body', async () => {
      req.body = undefined;

      await likeBooks(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        status: 'fail',
        message: 'liked_books must be an array of strings.'
      });
    });
  });
});