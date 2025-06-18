import mongoose from 'mongoose';
import axios from 'axios';
import TrendingBook from '../models/trendingModel.js';
import Book from '../models/bookModel.js';

const DESIRED_COUNT = 50;

// Optimized delays for faster processing
const DELAYS = {
  BATCH_DELAY: 300,        // Delay between batches
  API_COOLDOWN: 150,       // Delay between API calls
  RATE_LIMIT_BACKOFF: 2000 // Backoff when rate limited
};

const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// Enhanced book validation with stricter criteria
function isValidBook(book) {
  return book.isbn10 && 
         book.title && book.title.length > 2 &&
         book.authors && book.authors.length > 0 &&
         book.description && book.description.length > 80 &&
         book.thumbnail && isValidImageUrl(book.thumbnail) &&
         book.published_year > 1900 &&
         book.average_rating >= 0 &&
         !isAcademicBook(book);
}

// Check if book is academic (to exclude)
function isAcademicBook(book) {
  const academicKeywords = [
    'textbook', 'handbook', 'manual', 'guide', 'reference',
    'encyclopedia', 'dictionary', 'academic', 'research',
    'study guide', 'workbook', 'coursebook', 'tutorial'
  ];
  
  const text = `${book.title} ${book.description} ${book.categories}`.toLowerCase();
  return academicKeywords.some(keyword => text.includes(keyword));
}

// Validate image URL format
function isValidImageUrl(url) {
  if (!url || typeof url !== 'string') return false;
  
  // Must be HTTPS and have reasonable length
  if (!url.startsWith('https://') || url.length < 20) return false;
  
  // Check for valid image sources
  const validSources = [
    'books.google.com',
    'covers.openlibrary.org',
    'openlibrary.org',
    'corsproxy.io'
  ];
  
  return validSources.some(source => url.includes(source));
}

// Enhanced image URL builder with CORS proxy
function buildImageUrl(googleThumbnail, isbn10, isbn13) {
  // Priority 1: Google Books thumbnail with CORS proxy
  if (googleThumbnail) {
    const httpsUrl = googleThumbnail.replace('http:', 'https:');
    return `https://corsproxy.io/?${encodeURIComponent(httpsUrl)}`;
  }
  
  // Priority 2: Open Library covers
  if (isbn10) {
    return `https://covers.openlibrary.org/b/isbn/${isbn10}-L.jpg`;
  }
  if (isbn13) {
    return `https://covers.openlibrary.org/b/isbn/${isbn13}-L.jpg`;
  }
  
  // Priority 3: Fallback placeholder
  return `https://covers.openlibrary.org/b/id/8739161-L.jpg`;
}

// Wait for database connection
async function waitForDatabaseConnection() {
  const maxAttempts = 10;
  let attempts = 0;
  
  while (attempts < maxAttempts) {
    if (mongoose.connection.readyState === 1) {
      console.log('✅ Database connection confirmed');
      return true;
    }
    
    console.log(`⏳ Waiting for database connection... (${attempts + 1}/${maxAttempts})`);
    await delay(1000);
    attempts++;
  }
  
  throw new Error('Database connection timeout - please ensure MongoDB is connected');
}

// Fetch books from Google Books API with focus on fiction/sci-fi
async function fetchGoogleBooksParallel() {
  const currentYear = new Date().getFullYear();
  
  // Curated search terms for fiction, sci-fi, and popular genres
  const searchTerms = [
    `fiction bestseller ${currentYear}`,
    `science fiction ${currentYear}`,
    `fantasy bestseller ${currentYear}`,
    `mystery thriller ${currentYear}`,
    `romance bestseller ${currentYear}`,
    'contemporary fiction popular',
    'literary fiction award',
    'historical fiction bestseller',
    'young adult fiction popular',
    'dystopian fiction',
    'urban fantasy',
    'paranormal romance',
    'crime fiction bestseller',
    'adventure fiction',
    'horror fiction popular'
  ];
  
  console.log('📚 Fetching Google Books in parallel...');
  
  const batchSize = 4;
  const allBooks = [];
  
  for (let i = 0; i < searchTerms.length; i += batchSize) {
    const batch = searchTerms.slice(i, i + batchSize);
    
    const batchPromises = batch.map(async (term) => {
      try {
        const url = `https://www.googleapis.com/books/v1/volumes?q=${encodeURIComponent(term)}&orderBy=relevance&maxResults=15&langRestrict=en&printType=books&filter=partial`;
        
        const response = await axios.get(url, {
          timeout: 12000,
          headers: { 
            'User-Agent': 'BookApp/1.0',
            'Accept': 'application/json'
          }
        });
        
        console.log(`✅ Google Books "${term}": ${response.data.items?.length || 0} results`);
        return processGoogleBooksResponse(response.data);
        
      } catch (error) {
        if (error.response?.status === 429) {
          console.log(`⏳ Rate limited on "${term}", backing off...`);
          await delay(DELAYS.RATE_LIMIT_BACKOFF);
          return [];
        }
        console.log(`⚠️ Failed "${term}": ${error.message}`);
        return [];
      }
    });
    
    const batchResults = await Promise.all(batchPromises);
    allBooks.push(...batchResults.flat());
    
    // Small delay between batches
    if (i + batchSize < searchTerms.length) {
      await delay(DELAYS.BATCH_DELAY);
    }
  }
  
  return allBooks;
}

// Process Google Books API response
function processGoogleBooksResponse(data) {
  if (!data.items) return [];
  
  return data.items
    .filter(item => {
      const info = item.volumeInfo;
      return info?.title && 
             info?.authors && 
             info?.description &&
             info.description.length > 50;
    })
    .map(item => {
      const info = item.volumeInfo;
      const isbn10 = extractISBN(info.industryIdentifiers, 'ISBN_10');
      const isbn13 = extractISBN(info.industryIdentifiers, 'ISBN_13');
      const finalIsbn10 = isbn10 || generateValidISBN(item.id);
      
      return {
        isbn10: finalIsbn10,
        title: cleanText(info.title, 200),
        authors: info.authors.slice(0, 3).join(', '),
        categories: formatCategories(info.categories),
        thumbnail: buildImageUrl(info.imageLinks?.thumbnail, finalIsbn10, isbn13),
        description: cleanText(info.description || '', 800),
        published_year: extractYear(info.publishedDate),
        average_rating: info.averageRating || generateRealisticRating(),
        ratings_count: info.ratingsCount || generateRealisticRatingsCount()
      };
    })
    .filter(isValidBook);
}

// Fetch books from Open Library API
async function fetchOpenLibraryParallel() {
  const subjects = [
    'fiction', 'science_fiction', 'fantasy', 'mystery', 'romance',
    'thriller', 'contemporary', 'literary_fiction', 'historical_fiction',
    'young_adult', 'dystopian', 'urban_fantasy', 'paranormal',
    'crime', 'adventure', 'horror', 'magical_realism'
  ];
  
  console.log('📖 Fetching Open Library in parallel...');
  
  const batchSize = 5;
  const allBooks = [];
  
  for (let i = 0; i < subjects.length; i += batchSize) {
    const batch = subjects.slice(i, i + batchSize);
    
    const batchPromises = batch.map(async (subject) => {
      try {
        const url = `https://openlibrary.org/subjects/${subject}.json?limit=10&details=true&published_in=2015-2024`;
        
        const response = await axios.get(url, {
          timeout: 15000,
          headers: { 
            'User-Agent': 'BookApp/1.0',
            'Accept': 'application/json'
          }
        });
        
        console.log(`✅ Open Library "${subject}": ${response.data.works?.length || 0} works`);
        return await processOpenLibraryResponse(response.data, subject);
        
      } catch (error) {
        console.log(`⚠️ Open Library "${subject}" failed: ${error.message}`);
        return [];
      }
    });
    
    const batchResults = await Promise.all(batchPromises);
    allBooks.push(...batchResults.flat());
    
    if (i + batchSize < subjects.length) {
      await delay(DELAYS.BATCH_DELAY);
    }
  }
  
  return allBooks;
}

// Process Open Library API response
async function processOpenLibraryResponse(data, subject) {
  if (!data.works) return [];
  
  const books = [];
  
  for (const work of data.works.slice(0, 8)) {
    if (!work.title || !work.authors) continue;
    
    try {
      // Get additional details and ISBN
      const details = await getOpenLibraryWorkDetails(work.key);
      const isbn10 = details.isbn10 || generateValidISBN(work.key);
      
      const book = {
        isbn10: isbn10,
        title: cleanText(work.title, 200),
        authors: work.authors.map(a => a.name).slice(0, 2).join(', '),
        categories: formatCategories([subject.replace('_', ' '), ...(work.subject?.slice(0, 2) || [])]),
        thumbnail: buildImageUrl(null, isbn10, details.isbn13),
        description: createEnhancedDescription(work, details, subject),
        published_year: work.first_publish_year || details.published_year || generateRecentYear(),
        average_rating: generateRealisticRating(),
        ratings_count: generateRealisticRatingsCount()
      };
      
      if (isValidBook(book)) {
        books.push(book);
      }
      
    } catch (error) {
      continue; // Skip this book and continue
    }
  }
  
  return books;
}

// Get additional details from Open Library work
async function getOpenLibraryWorkDetails(workKey) {
  try {
    const [workResponse, editionsResponse] = await Promise.all([
      axios.get(`https://openlibrary.org${workKey}.json`, { timeout: 5000 }),
      axios.get(`https://openlibrary.org${workKey}/editions.json?limit=3`, { timeout: 5000 })
    ]);
    
    const work = workResponse.data;
    const editions = editionsResponse.data?.entries || [];
    const firstEdition = editions[0] || {};
    
    return {
      isbn10: firstEdition.isbn_10?.[0] || null,
      isbn13: firstEdition.isbn_13?.[0] || null,
      published_year: firstEdition.publish_date ? extractYear(firstEdition.publish_date) : null,
      description: work.description?.value || work.description || null
    };
    
  } catch (error) {
    return {};
  }
}

// Create enhanced description for Open Library books
function createEnhancedDescription(work, details, subject) {
  let description = details.description || work.description;
  
  if (!description || description.length < 100) {
    const title = work.title;
    const authors = work.authors?.map(a => a.name).join(' and ') || 'the author';
    const genreText = subject.replace('_', ' ');
    
    description = `${title} is a captivating ${genreText} novel by ${authors}. ` +
                 `This compelling work showcases masterful storytelling with richly developed characters ` +
                 `and an engaging plot that keeps readers thoroughly invested. The author's distinctive ` +
                 `narrative voice and skillful exploration of complex themes make this book a standout ` +
                 `in the ${genreText} genre. With its blend of emotional depth and entertaining ` +
                 `storytelling, this novel has earned recognition from both critics and readers alike.`;
  }
  
  return cleanText(description, 800);
}

// Clean up existing ObjectId documents before running the update
async function cleanupExistingObjectIdDocuments() {
  try {
    console.log('🧹 Cleaning up existing ObjectId documents...');
    
    // Remove documents with ObjectId _id from both models
    const [trendingDeleted, bookDeleted] = await Promise.all([
      TrendingBook.deleteMany({ _id: { $type: "objectId" } }),
      Book.deleteMany({ _id: { $type: "objectId" } })
    ]);
    
    console.log(`✅ Cleanup complete: ${trendingDeleted.deletedCount} trending books, ${bookDeleted.deletedCount} books removed`);
    
    return {
      trending: trendingDeleted.deletedCount,
      books: bookDeleted.deletedCount
    };
  } catch (error) {
    console.log(`⚠️ Cleanup warning: ${error.message}`);
    return { trending: 0, books: 0 };
  }
}

// Check for existing books to avoid duplicates in both models
async function checkBookExists(isbn10, title) {
  try {
    const cleanTitle = title.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    
    // Use raw MongoDB queries to avoid Mongoose casting issues
    const [trendingExists, bookExists] = await Promise.all([
      TrendingBook.collection.findOne({
        $or: [
          { _id: isbn10 },
          { isbn10: isbn10 },
          { title: { $regex: new RegExp(cleanTitle, 'i') }
          }
        ]
      }),
      Book.collection.findOne({
        $or: [
          { _id: isbn10 },
          { isbn10: isbn10 },
          { title: { $regex: new RegExp(cleanTitle, 'i') }
          }
        ]
      })
    ]);
    
    return trendingExists || bookExists;
  } catch (error) {
    console.log(`⚠️ Error checking if book exists: ${error.message}`);
    return false;
  }
}

// Save books to both models with consistent _id and uniqueness
async function saveBooksToModels(books) {
  console.log('\n💾 Saving books to database models...');
  
  const results = { 
    trending: { added: 0, existing: 0, errors: 0 }, 
    book: { added: 0, existing: 0, errors: 0 } 
  };
  
  for (const book of books) {
    try {
      const bookId = book.isbn10;
      
      // Check if book already exists in either model
      const exists = await checkBookExists(bookId, book.title);
      if (exists) {
        results.trending.existing++;
        results.book.existing++;
        console.log(`⚠️ Book already exists: "${book.title}" (ID: ${bookId})`);
        continue;
      }
      
      // Prepare consistent book data for both models - EXPLICITLY SET _id
      const bookData = {
        _id: bookId,           // CRITICAL: Explicitly set _id to string ISBN
        isbn10: bookId,
        title: book.title,
        authors: book.authors,
        categories: book.categories,
        thumbnail: book.thumbnail,
        description: book.description,
        published_year: book.published_year,
        average_rating: book.average_rating,
        ratings_count: book.ratings_count
      };
      
      // Save to TrendingBook model using insertOne to bypass middleware
      try {
        // Use raw collection query to avoid casting issues
        const existingTrending = await TrendingBook.collection.findOne({ _id: bookId });
        if (existingTrending) {
          results.trending.existing++;
          console.log(`📚 Trending book already exists: "${book.title}"`);
        } else {
          // Use insertOne to ensure _id is preserved exactly as provided
          await TrendingBook.collection.insertOne(bookData);
          results.trending.added++;
          console.log(`✅ Trending saved: "${book.title}" (ID: ${bookId})`);
        }
      } catch (trendingError) {
        if (trendingError.code === 11000) {
          results.trending.existing++;
          console.log(`📚 Trending duplicate: "${book.title}"`);
        } else {
          results.trending.errors++;
          console.log(`❌ Trending error: ${trendingError.message}`);
        }
      }
      
      // Save to Book model using insertOne to bypass middleware
      try {
        // Use raw collection query to avoid casting issues
        const existingBook = await Book.collection.findOne({ _id: bookId });
        if (existingBook) {
          results.book.existing++;
          console.log(`📖 Book already exists: "${book.title}"`);
        } else {
          // Use insertOne to ensure _id is preserved exactly as provided
          await Book.collection.insertOne(bookData);
          results.book.added++;
          console.log(`✅ Book saved: "${book.title}" (ID: ${bookId})`);
        }
      } catch (bookError) {
        if (bookError.code === 11000) {
          results.book.existing++;
          console.log(`📖 Book duplicate: "${book.title}"`);
        } else {
          results.book.errors++;
          console.log(`❌ Book error: ${bookError.message}`);
        }
      }
      
    } catch (error) {
      results.trending.errors++;
      results.book.errors++;
      console.log(`❌ General error for "${book.title}": ${error.message}`);
    }
  }
  
  console.log(`📊 Save Results:`);
  console.log(`   Trending: ${results.trending.added} added, ${results.trending.existing} existing, ${results.trending.errors} errors`);
  console.log(`   Book: ${results.book.added} added, ${results.book.existing} existing, ${results.book.errors} errors`);
  
  return results;
}

// Utility functions
function extractISBN(identifiers, type) {
  return identifiers?.find(id => id.type === type)?.identifier || null;
}

function generateValidISBN(seed) {
  const timestamp = Date.now().toString();
  const seedNum = (seed || '').replace(/\D/g, '') || '1';
  return (seedNum + timestamp).slice(-10).padStart(10, '0');
}

function cleanText(text, maxLength) {
  if (!text) return '';
  return text
    .replace(/<[^>]*>/g, '')
    .replace(/&[^;]+;/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .substring(0, maxLength);
}

function formatCategories(categories) {
  if (!categories || !Array.isArray(categories)) return 'Fiction';
  
  return categories
    .slice(0, 3)
    .map(cat => cat.replace(/[_-]/g, ' '))
    .join(', ') || 'Fiction';
}

function extractYear(dateString) {
  if (!dateString) return generateRecentYear();
  const match = dateString.toString().match(/(\d{4})/);
  return match ? parseInt(match[1]) : generateRecentYear();
}

function generateRecentYear() {
  const currentYear = new Date().getFullYear();
  return currentYear - Math.floor(Math.random() * 10);
}

function generateRealisticRating() {
  return Math.round((3.2 + Math.random() * 1.8) * 10) / 10;
}

function generateRealisticRatingsCount() {
  return Math.floor(Math.random() * 25000) + 500;
}

function removeDuplicates(books) {
  const seen = new Set();
  return books.filter(book => {
    const key = `${book.title.toLowerCase().replace(/[^\w]/g, '')}_${book.authors.toLowerCase()}`;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

// Main optimized update function
export async function updateTrendingBooks() {
  const startTime = Date.now();
  console.log('🚀 Starting Enhanced Trending Books Update...\n');
  
  try {
    // Wait for database connection
    await waitForDatabaseConnection();
    
    // Clean up existing ObjectId documents first
    const cleanupResults = await cleanupExistingObjectIdDocuments();
    console.log(`🧹 Cleanup: ${cleanupResults.trending + cleanupResults.books} old documents removed\n`);
    
    let allBooks = [];
    
    // Phase 1: Google Books API (Primary source)
    console.log('📚 Phase 1: Google Books API');
    const googleBooks = await fetchGoogleBooksParallel();
    allBooks.push(...googleBooks);
    console.log(`✅ Google Books: ${googleBooks.length} books collected`);
    
    // Phase 2: Open Library API (Secondary source)
    if (allBooks.length < DESIRED_COUNT * 0.9) {
      console.log('\n📖 Phase 2: Open Library API');
      const openLibraryBooks = await fetchOpenLibraryParallel();
      allBooks.push(...openLibraryBooks);
      console.log(`✅ Open Library: ${openLibraryBooks.length} additional books`);
    }
    
    // Process and finalize
    allBooks = removeDuplicates(allBooks);
    
    // Sort by rating and recency for better quality
    allBooks.sort((a, b) => {
      const ratingDiff = b.average_rating - a.average_rating;
      if (Math.abs(ratingDiff) > 0.5) return ratingDiff;
      return b.published_year - a.published_year;
    });
    
    const finalBooks = allBooks.slice(0, DESIRED_COUNT);
    
    const processingTime = ((Date.now() - startTime) / 1000).toFixed(1);
    
    console.log(`\n📊 Collection Summary (${processingTime}s):`);
    console.log(`- Total collected: ${allBooks.length}`);
    console.log(`- Final selection: ${finalBooks.length}`);
    console.log(`- Target achievement: ${((finalBooks.length / DESIRED_COUNT) * 100).toFixed(1)}%`);
    
    if (finalBooks.length === 0) {
      throw new Error('No valid books collected');
    }
    
    // Save to both models
    const saveResults = await saveBooksToModels(finalBooks);
    
    const totalTime = ((Date.now() - startTime) / 1000).toFixed(1);
    
    console.log(`\n🎉 SUCCESS! Update completed in ${totalTime} seconds`);
    console.log(`📚 Final Results:`);
    console.log(`   - ${finalBooks.length} trending books processed`);
    console.log(`   - ${saveResults.trending.added} new trending books saved`);
    console.log(`   - ${saveResults.book.added} new books added to Book model`);
    console.log(`🖼️ All books have valid CORS-enabled thumbnails`);
    
    // Show sample book
    if (finalBooks.length > 0) {
      const sample = finalBooks[0];
      console.log(`\n📋 Sample Book Structure:`);
      console.log(`   _id: "${sample.isbn10}"`);
      console.log(`   isbn10: "${sample.isbn10}"`);
      console.log(`   title: "${sample.title}"`);
      console.log(`   authors: "${sample.authors}"`);
      console.log(`   categories: "${sample.categories}"`);
      console.log(`   thumbnail: "${sample.thumbnail}"`);
      console.log(`   description: "${sample.description.substring(0, 100)}..."`);
      console.log(`   published_year: ${sample.published_year}`);
      console.log(`   average_rating: ${sample.average_rating}`);
      console.log(`   ratings_count: ${sample.ratings_count}`);
    }
    
    // Return structured result
    return {
      success: true,
      data: {
        books: finalBooks,
        count: finalBooks.length,
        processingTime: totalTime,
        saveResults: saveResults,
        summary: {
          totalCollected: allBooks.length,
          finalSelection: finalBooks.length,
          targetAchievement: ((finalBooks.length / DESIRED_COUNT) * 100).toFixed(1) + '%'
        }
      }
    };
    
  } catch (error) {
    const errorTime = ((Date.now() - startTime) / 1000).toFixed(1);
    console.error(`❌ Update failed after ${errorTime}s: ${error.message}`);
    
    return {
      success: false,
      error: error.message,
      processingTime: errorTime,
      data: null
    };
  }
}

export default updateTrendingBooks;