import User from "../models/userModel.js";
import dotenv from "dotenv";
import axios from "axios";
import TrendingBook from "../models/trendingModel.js";
import Book from "../models/bookModel.js";
import Rating from "../models/ratingModel.js";
import NodeCache from "node-cache";
import Review from "../models/reviewModel.js";
import Forum from "../models/forumModel.js";
import Report from "../models/reportModel.js";
import Comment from "../models/commentModel.js";

// Create a new book//yeha id ley create garni
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
    const  isbn  = req.params.id;
    const book = await Book.findById({ _id:isbn }).select('-__v');
    if (!book) return res.status(404).json({ status: 'fail', message: 'Book not found.' });
    res.status(200).json({ status: 'success', data: book });
  } catch (err) {
    next(err);
  }
};

// controllers/book.controller.js
export const getBooks = async (req, res, next) => {
  try {
    // 1) Parse page & limit
    const page  = Math.max(parseInt(req.query.page, 10)  || 1,  1);
    const limit = Math.max(parseInt(req.query.limit, 10) || 10, 1);
    const skip  = (page - 1) * limit;

    // 2) Total count
    const totalBooks = await Book.countDocuments();

    // 3) Fetch paginated, sorted newest-first
    const books = await Book.find()
      .select('-__v')
      .sort({ createdAt: -1 })  // <-- newest added first
      .skip(skip)
      .limit(limit);

    // 4) Send response
    res.status(200).json({
      status: 'success',
      results: books.length,
      page,
      limit,
      totalPages: Math.ceil(totalBooks / limit),
      totalBooks,
      data: books
    });
  } catch (err) {
    next(err);
  }
};


// Update a book by ISBN
export const updateBook = async (req, res, next) => {
  try {
    const isbn  = req.params.id;
    const book = await Book.findByIdAndUpdate({ _id: isbn }, req.body, { new: true, runValidators: true });
    if (!book) return res.status(404).json({ status: 'fail', message: 'Book not found.' });
    res.status(200).json({ status: 'success', data: book });
  } catch (err) {
    next(err);
  }
};

// Delete a book by ISBN
export const deleteBook = async (req, res, next) => {
  try {
    const isbn = req.params.id;
    const book = await Book.findByIdAndDelete({ _id: isbn });
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

export const getAllForums = async (req, res, next) => {
  try {
    const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
    const limit = Math.max(parseInt(req.query.limit, 10) || 10, 1);
    const skip = (page - 1) * limit;

    const [forums, totalMatches] = await Promise.all([
      Forum.find({})
        .populate('userId', 'fullName')
        .sort({ createdAt: -1 }) // newest first
        .skip(skip)
        .limit(limit),
      Forum.countDocuments(),
    ]);

    const totalPages = Math.ceil(totalMatches / limit);

    res.status(200).json({
      status: 'success',
      data: forums,
      pagination: {
        page,
        limit,
        totalMatches,
        totalPages,
      }
    });
  } catch (err) {
    next(err);
  }
};

export const getForumById = async (req, res, next) => {
  try {
    const { id } = req.params;

    const forum = await Forum.findById(id).populate('userId', 'fullName');

    if (!forum) {
      return res.status(404).json({ status: 'fail', message: 'Forum not found' });
    }

    res.status(200).json({ status: 'success', data: forum });
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


export const getAllUsers = async (req, res, next) => {
  try {
    // Parse page & limit from query, default to 1 & 10
    const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
    const limit = Math.max(parseInt(req.query.limit, 10) || 10, 1);
    const skip = (page - 1) * limit;

    // Fetch users and count in parallel
    const [users, totalUsers] = await Promise.all([
      User.find()
        .select('-password')
        .sort({ _id: -1 })   // newest first
        .skip(skip)
        .limit(limit),
      User.countDocuments(),
    ]);

    const totalPages = Math.ceil(totalUsers / limit);

    res.status(200).json({
      status: 'success',
      results: users.length,
      page,
      limit,
      totalPages,
      totalUsers,
      data: users,
    });
  } catch (err) {
    next(err);
  }
};

// Get user profile
export const getUserProfile = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
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
    await User.findByIdAndDelete(req.params.id);
    res.status(204).json({ status: 'success', data: null });
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


//controllers for report

export const createReport = async (req, res) => {
  try {
    const { type, targetId, content, createdBy } = req.body;
    const reporter = req.user.id;

    // optional: verify target exists
    let Model;
    if (type === 'comment') Model = Comment;
    else if (type === 'review') Model = Review;
    else if (type === 'forum')  Model = Forum;
    else throw new Error('Invalid report type');

    const target = await Model.findById(targetId);
    if (!target) {
      return res.status(404).json({ status:'fail', message:'Target not found' });
    }

    const report = await Report.create({
      type, targetId, content, reporter, createdBy
    });

    res.status(201).json({ status:'success', data: report });
  } catch (err) {
    res.status(500).json({ status:'error', message: err.message });
  }
};

/** 2) List / Search reports */
export const getReports = async (req, res) => {
  try {
    const { type, targetId, page = 1, limit = 10 } = req.query;
    const filter = {};
    if (type)     filter.type = type;
    if (targetId) filter.targetId = targetId;

    // Convert to numbers & enforce minimums
    const pageNum  = Math.max(parseInt(page, 10), 1);
    const limitNum = Math.max(parseInt(limit, 10), 1);
    const skip     = (pageNum - 1) * limitNum;

    // Get total count for metadata
    const totalReports = await Report.countDocuments(filter);

    // Fetch paginated results
    const reports = await Report.find(filter)
      .populate('reporter', 'fullName email')
      .populate('createdBy', 'fullName email')
      .sort('-createdAt')
      .skip(skip)
      .limit(limitNum);

    res.status(200).json({
      status: 'success',
      results: reports.length,
      page: pageNum,
      limit: limitNum,
      totalPages: Math.ceil(totalReports / limitNum),
      totalReports,
      data: reports
    });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
};

/** 3) View one report, plus its actual content */
export const getReportById = async (req, res) => {
  try {
    const report = await Report.findById(req.params.id)
      .populate('reporter', 'fullName email')
      .populate('createdBy', 'fullName email');

    if (!report) {
      return res.status(404).json({ status:'fail', message:'Report not found' });
    }

    // load the actual object being reported
    let related;
    switch (report.type) {
      case 'comment':
        related = await Comment.findById(report.targetId);
        break;
      case 'review':
        related = await Review.findById(report.targetId);
        break;
      case 'forum':
        related = await Forum.findById(report.targetId);
        break;
    }

    res.status(200).json({
      status:'success',
      data: { report, related }
    });
  } catch (err) {
    res.status(500).json({ status:'error', message: err.message });
  }
};


export const deleteReport = async (req, res) => {
  try {
    const report = await Report.findByIdAndDelete(req.params.id);
    if (!report) {
      return res.status(404).json({ status:'fail', message:'Report not found' });
    }
    res.status(200).json({ status:'success', message:'Report deleted' });
  } catch (err) {
    res.status(500).json({ status:'error', message: err.message });
  }
};