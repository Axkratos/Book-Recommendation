import User from '../models/userModel.js';
import dotenv from 'dotenv';
import axios from 'axios';
import TrendingBook from '../models/trendingModel.js';
import Book from '../models/bookModel.js';
import Rating from '../models/ratingModel.js';
import NodeCache from 'node-cache';


const searchCache = new NodeCache({ stdTTL: 1800 }); // 30 minutes for search results
const categoryCache = new NodeCache({ stdTTL: 3600 });
const cache = new NodeCache({ stdTTL: 3600, checkperiod: 120 });


dotenv.config(); // ← loads .env into process.env

const FASTAPI_URL = process.env.FASTAPI_URL || 'http://localhost:8000';


export const likeBooks = async (req, res) => {
  const  id  = req.user.id;// User ID
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

export const checkBookSelected = async (req, res) => {
  const userId = req.user.id;

  try {
    // Fetch only the liked_books field
    const user = await User.findById(userId).select('liked_books');

    if (!user) {
      return res.status(404).json({
        status: 'fail',
        message: 'User not found.'
      });
    }

    const bookSelected = Array.isArray(user.liked_books) && user.liked_books.length > 0;

    res.status(200).json({
      status: 'success',
      data: {
        bookSelected
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



export const addRating = async (req, res) => {
  const { ISBN, rating } = req.body;
  const userId = req.user.id; // 👈 this is your numeric User-ID

  // Basic validation
  if (
    !ISBN || typeof ISBN !== 'string' ||
    rating === undefined || typeof rating !== 'number' || rating < 0 || rating > 10
  ) {
    return res.status(400).json({
      status: 'fail',
      message: 'Request body must include { ISBN: String, rating: Number (0-10) }'
    });
  }

  try {
    // Check if user exists
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: 'fail',
        message: 'User not found.'
      });
    }

    // Check if rating already exists for this user and ISBN
    const existingRating = await Rating.findOne({ 'User-ID': userId, ISBN });
    if (existingRating) {
      // If exists, update it
      existingRating['Book-Rating'] = rating;
      await existingRating.save();
      return res.status(200).json({
        status: 'success',
        message: `Rating for ISBN ${ISBN} updated.`,
        data: existingRating
      });
    }

    // If not, create a new rating
    const newRating = await Rating.create({
      'User-ID': userId,
      ISBN,
      'Book-Rating': rating
    });

    res.status(201).json({
      status: 'success',
      message: `Rating for ISBN ${ISBN} added.`,
      data: newRating
    });

  } catch (err) {
    res.status(500).json({
      status: 'error',
      message: err.message
    });
  }
};


export const getRating = async (req, res) => {
  const ISBN = req.params.isbn10;
  const userId = req.user.id;

  if (!ISBN || typeof ISBN !== 'string') {
    return res.status(400).json({
      status: 'fail',
      message: 'Request params must include ISBN as a string.'
    });
  }

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: 'fail',
        message: 'User not found.'
      });
    }

    const existingRating = await Rating.findOne({ 'User-ID': userId, ISBN });

    if (existingRating) {
      return res.status(200).json({
        status: 'success',
        message: `Rating found for ISBN ${ISBN}.`,
        data: {
          rating: existingRating['Book-Rating']
        }
      });
    }

    return res.status(200).json({
      status: 'success',
      message: `No rating found for ISBN ${ISBN}.`,
      data: {
        rating: 0
      }
    });

  } catch (err) {
    res.status(500).json({
      status: 'error',
      message: err.message
    });
  }
};



export const getBooks = async (req, res) => {
  try {
    const { 
      categories = '', 
      page = 1, 
      limit = 10,
      sortByYear = '', // 'asc', 'desc', or empty
      minRating = 0,   // minimum average rating filter
      search = '',     // NEW: text search parameter
      searchFields = 'title,authors,description' // NEW: which fields to search in
    } = req.query;
    
    const pg = Math.max(1, parseInt(page, 10));
    const lim = Math.max(1, parseInt(limit, 10));
    const minRatingFilter = Math.max(0, parseFloat(minRating) || 0);
    const yearSort = ['asc', 'desc'].includes(sortByYear?.toLowerCase()) ? sortByYear.toLowerCase() : '';
    const searchText = search.trim();
    const fieldsToSearch = searchFields.split(',').map(f => f.trim());

    // Build sort object based on parameters
    let sortCriteria = {};
    if (yearSort === 'asc') {
      sortCriteria.published_year = 1;
    } else if (yearSort === 'desc') {
      sortCriteria.published_year = -1;
    } else {
      // Default sorting by rating and review count
      sortCriteria = { 
        average_rating: -1,
        ratings_count: -1 
      };
    }

    // Build base query with rating filter
    let baseQuery = {};
    if (minRatingFilter > 0) {
      baseQuery.average_rating = { $gte: minRatingFilter };
    }

    // Handle text search
    if (searchText) {
      return await handleTextSearch(req, res, {
        searchText,
        fieldsToSearch,
        categories,
        baseQuery,
        sortCriteria,
        pg,
        lim,
        yearSort,
        minRatingFilter
      });
    }

    // Handle category-based search (existing logic)
    return await handleCategorySearch(req, res, {
      categories,
      baseQuery,
      sortCriteria,
      pg,
      lim,
      yearSort,
      minRatingFilter
    });

  } catch (err) {
    console.error('Error in getBooks:', err);
    res.status(500).json({ status: 'error', message: err.message });
  }
};

// NEW: Handle text-based search
const handleTextSearch = async (req, res, params) => {
  const {
    searchText,
    fieldsToSearch,
    categories,
    baseQuery,
    sortCriteria,
    pg,
    lim,
    yearSort,
    minRatingFilter
  } = params;

  // Create cache key for search results
  const cacheKey = `search_${searchText}_${fieldsToSearch.join('_')}_${categories}_${yearSort}_${minRatingFilter}`;
  let searchResults = searchCache.get(cacheKey);

  if (!searchResults) {
    // Build text search query
    const searchQuery = { ...baseQuery };
    
    // Create text search conditions
    const textSearchConditions = [];
    
    // MongoDB text search (if you have text index)
    if (fieldsToSearch.includes('title') || fieldsToSearch.includes('authors') || fieldsToSearch.includes('description')) {
      textSearchConditions.push({
        $text: { $search: searchText }
      });
    }
    
    // Regex search for more flexible matching
    const regexSearchConditions = [];
    const searchRegex = new RegExp(searchText.split(' ').join('|'), 'i');
    
    if (fieldsToSearch.includes('title')) {
      regexSearchConditions.push({ title: { $regex: searchRegex } });
    }
    if (fieldsToSearch.includes('authors')) {
      regexSearchConditions.push({ authors: { $regex: searchRegex } });
    }
    if (fieldsToSearch.includes('description')) {
      regexSearchConditions.push({ description: { $regex: searchRegex } });
    }
    
    // Combine search conditions
    if (regexSearchConditions.length > 0) {
      searchQuery.$or = regexSearchConditions;
    }

    // Add category filter if provided
    if (categories.trim()) {
      const reqCats = categories
        .toLowerCase()
        .split(/[,&;\/]+/)
        .map(s => s.trim())
        .filter(Boolean);
      
      searchQuery.categories = {
        $regex: reqCats.join('|'),
        $options: 'i'
      };
    }

    console.log(`Performing text search for: "${searchText}" in fields: ${fieldsToSearch.join(', ')}`);
    
    // Execute search query
    const books = await Book.find(searchQuery)
      .sort(sortCriteria)
      .limit(5000); // Limit initial results for performance

    // Calculate relevance scores for search results
    searchResults = books.map(book => {
      let relevanceScore = 0;
      const searchTerms = searchText.toLowerCase().split(' ').filter(Boolean);
      
      // Score based on title matches (highest weight)
      if (fieldsToSearch.includes('title') && book.title) {
        const titleLower = book.title.toLowerCase();
        searchTerms.forEach(term => {
          if (titleLower.includes(term)) {
            relevanceScore += titleLower.startsWith(term) ? 10 : 5; // Bonus for starting match
          }
        });
      }
      
      // Score based on author matches (medium weight)
      if (fieldsToSearch.includes('authors') && book.authors) {
        const authorsLower = book.authors.toLowerCase();
        searchTerms.forEach(term => {
          if (authorsLower.includes(term)) {
            relevanceScore += 3;
          }
        });
      }
      
      // Score based on description matches (lower weight)
      if (fieldsToSearch.includes('description') && book.description) {
        const descLower = book.description.toLowerCase();
        searchTerms.forEach(term => {
          if (descLower.includes(term)) {
            relevanceScore += 1;
          }
        });
      }
      
      // Category relevance score (if categories were filtered)
      let categoryScore = 0;
      if (categories.trim()) {
        const reqCats = categories.toLowerCase().split(/[,&;\/]+/).map(s => s.trim()).filter(Boolean);
        const bookCats = (book.categories || '').toLowerCase().split(/[,&;\/\s]+/).map(s => s.trim()).filter(Boolean);
        
        let exactMatches = 0;
        let partialMatches = 0;
        
        for (const reqCat of reqCats) {
          for (const bookCat of bookCats) {
            if (bookCat === reqCat) {
              exactMatches++;
              break;
            } else if (bookCat.includes(reqCat) || reqCat.includes(bookCat)) {
              partialMatches++;
              break;
            }
          }
        }
        
        categoryScore = (exactMatches * 1.0 + partialMatches * 0.5) / reqCats.length;
      }
      
      return {
        book,
        relevanceScore,
        categoryScore: categoryScore || 0
      };
    });

    // Sort by relevance, then by category match, then by user preference
    searchResults.sort((a, b) => {
      // Primary: relevance score
      if (b.relevanceScore !== a.relevanceScore) {
        return b.relevanceScore - a.relevanceScore;
      }
      
      // Secondary: category relevance
      if (b.categoryScore !== a.categoryScore) {
        return b.categoryScore - a.categoryScore;
      }
      
      // Tertiary: user sort preference
      if (yearSort === 'asc') {
        return (a.book.published_year || 0) - (b.book.published_year || 0);
      } else if (yearSort === 'desc') {
        return (b.book.published_year || 0) - (a.book.published_year || 0);
      } else {
        // Default: rating and review count
        if (b.book.average_rating !== a.book.average_rating) {
          return (b.book.average_rating || 0) - (a.book.average_rating || 0);
        }
        return (b.book.ratings_count || 0) - (a.book.ratings_count || 0);
      }
    });

    // Cache the search results
    searchCache.set(cacheKey, searchResults);
    console.log(`Cached ${searchResults.length} search results for: "${searchText}"`);
  }

  // Paginate results
  const start = (pg - 1) * lim;
  const paginated = searchResults.slice(start, start + lim);

  return res.status(200).json({
    status: 'success',
    results: paginated.length,
    data: paginated.map(({ book, relevanceScore, categoryScore }) => ({
      ...book.toObject(),
      relevanceScore,
      categoryScore
    })),
    pagination: {
      page: pg,
      limit: lim,
      totalMatches: searchResults.length
    },
    filters: {
      searchText,
      searchFields: fieldsToSearch.join(', '),
      categories: categories.trim(),
      sortByYear: yearSort,
      minRating: minRatingFilter
    }
  });
};

// Existing category search logic (refactored)
const handleCategorySearch = async (req, res, params) => {
  const {
    categories,
    baseQuery,
    sortCriteria,
    pg,
    lim,
    yearSort,
    minRatingFilter
  } = params;

  // If no categories provided, return books with filters
  if (!categories.trim()) {
    const books = await Book.find(baseQuery)
      .sort(sortCriteria)
      .skip((pg - 1) * lim)
      .limit(lim);
    
    const totalBooks = await Book.countDocuments(baseQuery);
    
    return res.status(200).json({
      status: 'success',
      results: books.length,
      data: books.map(book => ({ ...book.toObject(), similarity: 0 })),
      pagination: {
        page: pg,
        limit: lim,
        totalMatches: totalBooks
      },
      filters: {
        categories: '',
        sortByYear: yearSort,
        minRating: minRatingFilter
      }
    });
  }

  // Parse requested categories
  const reqCats = categories
    .toLowerCase()
    .split(/[,&;\/]+/)
    .map(s => s.trim())
    .filter(Boolean);

  // Create cache key with all filters
  const cacheKey = `books_${reqCats.sort().join('_')}_${yearSort}_${minRatingFilter}`;
  let scored = categoryCache.get(cacheKey);

  if (!scored) {
    // Build query with rating filter
    const query = {
      ...baseQuery,
      categories: { 
        $regex: reqCats.join('|'), 
        $options: 'i' 
      }
    };
    
    // Apply minimum rating filter or default
    if (!query.average_rating && minRatingFilter === 0) {
      query.average_rating = { $gte: 3.0 }; // Default: only decent ratings
    }

    // Get candidate books
    const candidateBooks = await Book.find(query)
      .sort(sortCriteria)
      .limit(2000);

    console.log(`Processing ${candidateBooks.length} candidate books for categories: ${reqCats.join(', ')}`);

    // Calculate similarity scores
    scored = candidateBooks.map(book => {
      const bookCats = book.categories
        .toLowerCase()
        .split(/[,&;\/\s]+/)
        .map(s => s.trim())
        .filter(Boolean);

      let exactMatches = 0;
      let partialMatches = 0;
      
      for (const reqCat of reqCats) {
        for (const bookCat of bookCats) {
          if (bookCat === reqCat) {
            exactMatches++;
            break;
          } else if (bookCat.includes(reqCat) || reqCat.includes(bookCat)) {
            partialMatches++;
            break;
          }
        }
      }

      const score = (exactMatches * 1.0 + partialMatches * 0.5) / reqCats.length;
      return { book, score };
    });

    // Sort by similarity score and user preferences
    scored.sort((a, b) => {
      if (b.score !== a.score) return b.score - a.score;
      
      if (yearSort === 'asc') {
        return (a.book.published_year || 0) - (b.book.published_year || 0);
      } else if (yearSort === 'desc') {
        return (b.book.published_year || 0) - (a.book.published_year || 0);
      } else {
        if (b.book.average_rating !== a.book.average_rating) {
          return (b.book.average_rating || 0) - (a.book.average_rating || 0);
        }
        return (b.book.ratings_count || 0) - (a.book.ratings_count || 0);
      }
    });

    categoryCache.set(cacheKey, scored);
    console.log(`Cached ${scored.length} scored results for categories: ${reqCats.join(', ')}`);
  }

  // Paginate results
  const start = (pg - 1) * lim;
  const paginated = scored.slice(start, start + lim);

  return res.status(200).json({
    status: 'success',
    results: paginated.length,
    data: paginated.map(({ book, score }) => ({
      ...book.toObject(),
      similarity: score
    })),
    pagination: {
      page: pg,
      limit: lim,
      totalMatches: scored.length
    },
    filters: {
      categories: reqCats.join(', '),
      sortByYear: yearSort,
      minRating: minRatingFilter
    }
  });
};

const getBookDetails = async (isbn) => {
  const cacheKey = `book:${isbn}`;
  let book = cache.get(cacheKey);
  if (book) return book;

  book = await Book.findById(isbn).lean();
  if (book) {
    cache.set(cacheKey, book);
  }

  return book;
};


export const getItemBasedRecommendations = async (req, res) => {
  const userId = req.user.id;
  const limit = parseInt(req.query.limit, 10) || 20;

  try {
    // Fetch user's liked books (last 4)
    const user = await User.findById(userId).select('liked_books');
    if (!user) return res.status(404).json({ status: 'fail', message: 'User not found.' });

    const recentTitles = user.liked_books.slice(-4);
    if (recentTitles.length === 0) {
      return res.status(400).json({ status: 'fail', message: 'Not enough liked books to generate recommendations.' });
    }

    // Call FastAPI for item-based recommendations
    const response = await axios.post(
      `${FASTAPI_URL}/recommend/item/balanced`,
      { book_titles: recentTitles, limit }
    );

    const recs = response.data;
    const detailedRecs = [];
    const isbnList = [];

    for (const { isbn } of recs) {
      const book = await getBookDetails(isbn);
      if (book) {
        detailedRecs.push(book);
        isbnList.push(isbn);
      }
    }

    // Update user's itembased recommendations
    user.recommendation.itembased = isbnList;
    await user.save();

    return res.status(200).json({ status: 'success', data: detailedRecs });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ status: 'error', message: err.message });
  }
};


export const getItemBasedRecommendationsByTitle = async (req, res) => {
  const { title } = req.params;
  const limit  = parseInt(req.query.limit, 10) || 15;

  if (!title) {
    return res
      .status(400)
      .json({ status: 'fail', message: 'Book title is required in URL params.' });
  }

  try {
    // Build the exact payload you want FastAPI to see
    const payload = {
      "book_titles": [ title ],
      "limit": limit
    };
    console.log(payload)

    // Make sure JSON is sent
    const response = await axios.post(
      `${FASTAPI_URL}/recommend/item/balanced`,
      payload,
      {
        headers: {
          'Content-Type': 'application/json'
        }
      }
    );

    // FastAPI should reply with an array of { isbn } objects
    const recs = response.data;

    // Enrich with your getBookDetails
    const detailedRecs = await Promise.all(
      recs.map(async ({ isbn }) => getBookDetails(isbn))
    );

    return res
      .status(200)
      .json({ status: 'success', data: detailedRecs.filter(b => b) });

  } catch (err) {
    // If FastAPI returned a non-2xx, axios puts its body on err.response.data
    const status  = err.response?.status  || 500;
    const message = err.response?.data?.message || err.message;

    console.error('[ERROR] FastAPI call failed:', status, message);
    return res.status(status).json({ status: 'error', message });
  }
};

export const getBookByISBN = async (req, res) => {
  const { isbn } = req.params;

  try {
    const book = await Book.findById(isbn); // since _id === isbn10

    if (!book) {
      return res.status(404).json({
        status: 'fail',
        message: 'Book not found.'
      });
    }

    res.status(200).json({
      status: 'success',
      data: {
        book
      }
    });
  } catch (err) {
    res.status(500).json({
      status: 'error',
      message: err.message
    });
  }
};

export const getUserBasedRecommendations = async (req, res) => {
  const userId = req.user.id;
  const { limit = 20, min_rating_threshold = 1.0 } = req.body;

  try {
    const response = await axios.post(
      `${FASTAPI_URL}/recommend/user`,
      { user_id: userId, limit, min_rating_threshold }
    );

    const recs = response.data;
    const detailedRecs = [];
    const isbnList = [];

    for (const { isbn } of recs) {
      const book = await getBookDetails(isbn);
      if (book) {
        detailedRecs.push(book);
        isbnList.push(isbn);
      }
    }

    const user = await User.findById(userId).select('recommendation');
    user.recommendation.userbased = isbnList;
    await user.save();

    return res.status(200).json({ status: 'success', data: detailedRecs });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ status: 'error', message: err.message });
  }
};

export const getRandomUnratedBooks = async (req, res) => {
  try {
    const userId = req.user.id; // assuming you have user ID on req.user

    // 1. Find all ISBNs this user has rated
    const ratedISBNs = await Rating.find({ 'User-ID': userId })
      .distinct('ISBN');

    // 2. Aggregate on Book to exclude those ISBNs and pick a random sample
    const randomBooks = await Book.aggregate([
      { $match: { _id: { $nin: ratedISBNs } } },
      { $sample: { size: 20 } }
    ]);

    res.status(200).json({
      status: 'success',
      results: randomBooks.length,
      data: {
        books: randomBooks
      }
    });
  } catch (err) {
    console.error('Error fetching random unrated books:', err);
    res.status(500).json({
      status: 'error',
      message: 'An error occurred while fetching books.'
    });
  }
};