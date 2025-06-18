// routes/adminRoutes.js
import express from 'express';
import {
  createBook,
  getBook,
  getBooks,
  updateBook,
  deleteBook,
  createForum,
  getForumsByISBN,
  updateForum,
  deleteForum,

  createReview,
  getReviewsByISBN,
  updateReview,
  deleteReview,
  createComment,
  getCommentsByForum,
  updateComment,
  deleteComment,
  getUserProfile,
  updateUserProfile,
  deleteUser,
  getAllUsers,
  getDashboardStats
} from '../controllers/adminController.js';
import { protect, restrictTo } from '../middlewares/authMiddleware.js';

const router = express.Router();

// Protect all routes and restrict to admin
router.use(protect);
router.use(restrictTo('admin'));

// Book routes
router.post('/books', createBook);
router.get('/books', getBooks);
router.get('/books/:isbn', getBook);
router.patch('/books/:isbn', updateBook);
router.delete('/books/:isbn', deleteBook);

// Forum routes
router.post('/forums', createForum);
router.get('/forums/book/:isbn', getForumsByISBN);
router.patch('/forums/:id', updateForum);
router.delete('/forums/:id', deleteForum);


// Review routes
router.post('/reviews', createReview);
router.get('/reviews/book/:isbn', getReviewsByISBN);
router.patch('/reviews/:id', updateReview);
router.delete('/reviews/:id', deleteReview);

// Comment routes
router.post('/comments', createComment);
router.get('/comments/forum/:forumId', getCommentsByForum);
router.patch('/comments/:id', updateComment);
router.delete('/comments/:id', deleteComment);

// User profile routes (admin can view/edit any profile too)
router.get('/users/me', getUserProfile);
router.patch('/users/me', updateUserProfile);
router.delete('/users/me', deleteUser);

// Admin-specific routes
router.get('/users', getAllUsers);
router.get('/stats', getDashboardStats);

export default router;
