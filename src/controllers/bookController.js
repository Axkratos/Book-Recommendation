import User from '../models/userModel.js';
import dotenv from 'dotenv';
import axios from 'axios';
import TrendingBook from '../models/trendingModel.js';

dotenv.config(); // ← loads .env into process.env

const FASTAPI_URL = process.env.FASTAPI_URL || 'http://localhost:8000';


export const likeBooks = async (req, res) => {
  const  id  = req.user.id;; // User ID
  const { liked_books } = req.body; // Expect: { liked_books: ['Book 1', 'Book 2'] }

  if (!Array.isArray(liked_books)) {
    return res.status(400).json({
      status: 'fail',
      message: 'liked_books must be an array of strings.'
    });
  }

  try {
    const user = await User.findByIdAndUpdate(
      id,
      { $addToSet: { liked_books: { $each: liked_books } } }, // prevents duplicates
      { new: true }
    );

    if (!user) {
      return res.status(404).json({
        status: 'fail',
        message: 'User not found.'
      });
    }

    res.status(200).json({
      status: 'success',
      data: {
        liked_books: user.liked_books
      }
    });
  } catch (err) {
    res.status(500).json({
      status: 'error',
      message: err.message
    });
  }
};


// POST /api/recommend
export const getLLMRecommendations = async (req, res) => {
  const text  = req.body.text; // e.g. "a book where king dies"
  if (!text || typeof text !== 'string') {
    return res.status(400).json({ status: 'fail', message: 'Missing or invalid "text" in body.' });
  }

  try {
    // Build full URL from env var:
    const endpoint = `${FASTAPI_URL}/recommend`;

    const response = await axios.post(
      endpoint,
      { text },
      { headers: { 'Content-Type': 'application/json' } }
    );

    // response.data is assumed to be the array of books
    return res.status(200).json(response.data);
  } catch (err) {
    console.error('Error fetching from FastAPI:', err.message);
    return res.status(500).json({
      status: 'error',
      message: 'Failed to fetch recommendations from FastAPI.',
    });
  }
};
export const getTrendingBooks = async (req, res) => {
  try {
    // Fetch up to 50 books, sorted by most recent published_year
    const books = await TrendingBook.find({})
      .sort({ published_year: -1 })
      .limit(50)
      .lean();

    return res.status(200).json({
      status: 'success',
      data: books
    });
  } catch (err) {
    console.error('Error fetching trending books:', err);
    return res.status(500).json({
      status: 'error',
      message: 'Unable to retrieve trending books.'
    });
  }
};





