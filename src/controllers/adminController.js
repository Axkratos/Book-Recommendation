import User from "../models/userModel.js";
import dotenv from "dotenv";
import axios from "axios";
import TrendingBook from "../models/trendingModel.js";
import Book from "../models/bookModel.js";
import Rating from "../models/ratingModel.js";
import NodeCache from "node-cache";
import Review from "../models/reviewModel.js";
import Forum from "../models/forumModel.js";


// Create a new book
export const createBook = async (req, res, next) => {
  try {
    const book = await Book.create(req.body);
    res.status(201).json({ status: 'success', data: book });
  } catch (err) {
    next(err);
  }
};

// Get a single book by ISBN
export const getBook = async (req, res, next) => {
  try {
    const { isbn } = req.params;
    const book = await Book.findOne({ isbn10: isbn }).select('-__v');
    if (!book) return res.status(404).json({ status: 'fail', message: 'Book not found.' });
    res.status(200).json({ status: 'success', data: book });
  } catch (err) {
    next(err);
  }
};

// Get all books (with optional filters)
export const getBooks = async (req, res, next) => {
  try {
    const books = await Book.find().select('-__v');
    res.status(200).json({ status: 'success', data: books });
  } catch (err) {
    next(err);
  }
};

// Update a book by ISBN
export const updateBook = async (req, res, next) => {
  try {
    const { isbn } = req.params;
    const book = await Book.findOneAndUpdate({ isbn10: isbn }, req.body, { new: true, runValidators: true });
    if (!book) return res.status(404).json({ status: 'fail', message: 'Book not found.' });
    res.status(200).json({ status: 'success', data: book });
  } catch (err) {
    next(err);
  }
};

// Delete a book by ISBN
export const deleteBook = async (req, res, next) => {
  try {
    const { isbn } = req.params;
    const book = await Book.findOneAndDelete({ isbn10: isbn });
    if (!book) return res.status(404).json({ status: 'fail', message: 'Book not found.' });
    res.status(204).json({ status: 'success', data: null });
  } catch (err) {
    next(err);
  }
};



// Create a new discussion thread
export const createForum = async (req, res, next) => {
  try {
    const thread = await Forum.create({ userId: req.user.id, ...req.body });
    res.status(201).json({ status: 'success', data: thread });
  } catch (err) {
    next(err);
  }
};

// Get threads by ISBN
export const getForumsByISBN = async (req, res, next) => {
  try {
    const { isbn } = req.params;
    const threads = await Forum.find({ ISBN: isbn }).populate('userId', 'fullName');
    res.status(200).json({ status: 'success', data: threads });
  } catch (err) {
    next(err);
  }
};

// Update a thread
export const updateForum = async (req, res, next) => {
  try {
    const { id } = req.params;
    const thread = await Forum.findByIdAndUpdate(id, req.body, { new: true, runValidators: true });
    if (!thread) return res.status(404).json({ status: 'fail', message: 'Thread not found.' });
    res.status(200).json({ status: 'success', data: thread });
  } catch (err) {
    next(err);
  }
};

// Delete a thread
export const deleteForum = async (req, res, next) => {
  try {
    const { id } = req.params;
    const thread = await Forum.findByIdAndDelete(id);
    if (!thread) return res.status(404).json({ status: 'fail', message: 'Thread not found.' });
    res.status(204).json({ status: 'success', data: null });
  } catch (err) {
    next(err);
  }
};





// Create a review
export const createReview = async (req, res, next) => {
  try {
    const review = await Review.create({ user: req.user.id, userName: req.user.fullName, ...req.body });
    res.status(201).json({ status: 'success', data: review });
  } catch (err) {
    next(err);
  }
};

// Get reviews by ISBN
export const getReviewsByISBN = async (req, res, next) => {
  try {
    const { isbn } = req.params;
    const reviews = await Review.find({ isbn }).sort('-createdAt');
    res.status(200).json({ status: 'success', data: reviews });
  } catch (err) {
    next(err);
  }
};

// Update a review
export const updateReview = async (req, res, next) => {
  try {
    const { id } = req.params;
    const review = await Review.findByIdAndUpdate(id, req.body, { new: true, runValidators: true });
    if (!review) return res.status(404).json({ status: 'fail', message: 'Review not found.' });
    res.status(200).json({ status: 'success', data: review });
  } catch (err) {
    next(err);
  }
};

// Delete a review
export const deleteReview = async (req, res, next) => {
  try {
    const { id } = req.params;
    const review = await Review.findByIdAndDelete(id);
    if (!review) return res.status(404).json({ status: 'fail', message: 'Review not found.' });
    res.status(204).json({ status: 'success', data: null });
  } catch (err) {
    next(err);
  }
};




// Create a comment
export const createComment = async (req, res, next) => {
  try {
    const comment = await Comment.create({ userId: req.user.id, ...req.body });
    res.status(201).json({ status: 'success', data: comment });
  } catch (err) {
    next(err);
  }
};

// Get comments for a forum thread
export const getCommentsByForum = async (req, res, next) => {
  try {
    const { forumId } = req.params;
    const comments = await Comment.find({ forumId }).sort('createdAt');
    res.status(200).json({ status: 'success', data: comments });
  } catch (err) {
    next(err);
  }
};

// Update a comment
export const updateComment = async (req, res, next) => {
  try {
    const { id } = req.params;
    const comment = await Comment.findByIdAndUpdate(id, req.body, { new: true, runValidators: true });
    if (!comment) return res.status(404).json({ status: 'fail', message: 'Comment not found.' });
    res.status(200).json({ status: 'success', data: comment });
  } catch (err) {
    next(err);
  }
};

// Delete a comment
export const deleteComment = async (req, res, next) => {
  try {
    const { id } = req.params;
    const comment = await Comment.findByIdAndDelete(id);
    if (!comment) return res.status(404).json({ status: 'fail', message: 'Comment not found.' });
    res.status(204).json({ status: 'success', data: null });
  } catch (err) {
    next(err);
  }
};




// Get user profile
export const getUserProfile = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    res.status(200).json({ status: 'success', data: user });
  } catch (err) {
    next(err);
  }
};

// Update user profile
export const updateUserProfile = async (req, res, next) => {
  try {
    const updates = { fullName: req.body.fullName, email: req.body.email };
    const user = await User.findByIdAndUpdate(req.user.id, updates, { new: true, runValidators: true }).select('-password');
    res.status(200).json({ status: 'success', data: user });
  } catch (err) {
    next(err);
  }
};

// Delete user (deactivate)
export const deleteUser = async (req, res, next) => {
  try {
    await User.findByIdAndDelete(req.user.id);
    res.status(204).json({ status: 'success', data: null });
  } catch (err) {
    next(err);
  }
};


export const getAllUsers = async (req, res, next) => {
  try {
    const users = await User.find().select('-password');
    res.status(200).json({ status: 'success', data: users });
  } catch (err) {
    next(err);
  }
};

// Admin: Get dashboard stats
export const getDashboardStats = async (req, res, next) => {
  try {
    const bookCount = await Book.countDocuments();
    const userCount = await User.countDocuments();
    const forumCount = await Forum.countDocuments();
    const reviewCount = await Review.countDocuments();
    // console.log(bookCount, userCount, forumCount, reviewCount);
    res.status(200).json({
      status: 'success',
      data: {
        books: bookCount,
        users: userCount,
        forums: forumCount,
        reviews: reviewCount
      }
    });
  } catch (err) {
    next(err);
  }
};