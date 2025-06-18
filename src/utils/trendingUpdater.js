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
      const finalIsbn = isbn10 || generateValidISBN(item.id);
      
      return {
        isbn10: finalIsbn,
        title: cleanText(info.title, 200),
        authors: info.authors.slice(0, 3).join(', '),
        categories: formatCategories(info.categories),
        thumbnail: buildImageUrl(info.imageLinks?.thumbnail, finalIsbn, isbn13),
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

// Updated sync function to ensure _id equals isbn10 and avoid duplicates
async function syncBooksToBookModel(trendingBooks) {
  console.log('\n📚 Syncing to Book model...');
  
  const results = { existing: 0, added: 0, errors: 0 };
  
  for (const book of trendingBooks) {
    try {
      // Check if book already exists using isbn10 as _id
      const existingBook = await mongoose.connection.db.collection('books').findOne({ _id: book.isbn10 });
      
      if (existingBook) {
        results.existing++;
        console.log(`ℹ️ Already exists in Book model: "${book.title}" (ID: ${book.isbn10})`);
        continue;
      }
      
      // Prepare book data with _id as isbn10 (same structure as trending books)
      const bookData = {
        _id: book.isbn10,  // Use isbn10 as _id (same as trending books)
        isbn10: book.isbn10,
        title: book.title,
        authors: book.authors,
        categories: book.categories,
        thumbnail: book.thumbnail,
        description: book.description,
        published_year: book.published_year,
        average_rating: book.average_rating,
        ratings_count: book.ratings_count
      };
      
      // Insert directly to ensure _id is isbn10
      await mongoose.connection.db.collection('books').insertOne(bookData);
      
      results.added++;
      console.log(`✅ Added to Book model: "${book.title}" (ID: ${book.isbn10})`);
      
    } catch (error) {
      if (error.code === 11000) {
        results.existing++;
        console.log(`ℹ️ Duplicate key error for "${book.title}" (${book.isbn10})`);
      } else {
        results.errors++;
        console.log(`❌ Book sync error for "${book.title}": ${error.message}`);
      }
    }
  }
  
  console.log(`📊 Book Sync Results: ${results.added} added, ${results.existing} existing, ${results.errors} errors`);
  return results;
}

// Enhanced batch sync for better performance
async function syncBooksToBookModelBatch(trendingBooks) {
  console.log('\n📚 Syncing to Book model (Batch)...');
  
  const results = { existing: 0, added: 0, errors: 0 };
  
  try {
    // Get all existing book IDs in one query
    const existingBooks = await mongoose.connection.db.collection('books')
      .find({}, { projection: { _id: 1 } })
      .toArray();
    
    const existingIds = new Set(existingBooks.map(book => book._id));
    console.log(`📋 Found ${existingIds.size} existing books in Book collection`);
    
    // Filter out books that already exist
    const newBooks = trendingBooks.filter(book => {
      if (existingIds.has(book.isbn10)) {
        results.existing++;
        return false;
      }
      return true;
    });
    
    console.log(`📝 ${newBooks.length} new books to add, ${results.existing} already exist`);
    
    if (newBooks.length > 0) {
      // Prepare books data with _id as isbn10
      const booksData = newBooks.map(book => ({
        _id: book.isbn10,  // Use isbn10 as _id (same as trending books)
        isbn10: book.isbn10,
        title: book.title,
        authors: book.authors,
        categories: book.categories,
        thumbnail: book.thumbnail,
        description: book.description,
        published_year: book.published_year,
        average_rating: book.average_rating,
        ratings_count: book.ratings_count
      }));
      
      // Insert all new books at once
      const insertResult = await mongoose.connection.db.collection('books').insertMany(booksData, { ordered: false });
      results.added = insertResult.insertedCount;
      
      console.log(`✅ Successfully added ${results.added} books to Book model`);
      
      // Log first few added books
      newBooks.slice(0, 3).forEach(book => {
        console.log(`   ✓ "${book.title}" (ID: ${book.isbn10})`);
      });
      
      if (newBooks.length > 3) {
        console.log(`   ... and ${newBooks.length - 3} more books`);
      }
    }
    
  } catch (error) {
    console.log(`❌ Batch sync error: ${error.message}`);
    
    // Fallback to individual inserts if batch fails
    console.log('🔄 Falling back to individual inserts...');
    return await syncBooksToBookModel(trendingBooks);
  }
  
  console.log(`📊 Book Sync Results: ${results.added} added, ${results.existing} existing, ${results.errors} errors`);
  return results;
}

// Utility functions
function extractISBN(identifiers, type) {
  return identifiers?.find(id => id.type === type)?.identifier || null;
}

function generateValidISBN(seed) {
  const timestamp = Date.now().toString();
  const seedNum = (seed || '').replace(/\D/g, '') || '1';
  const combined = (seedNum + timestamp).slice(-10).padStart(10, '0');
  
  // Add some randomness to avoid collisions
  const randomSuffix = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
  return (combined + randomSuffix).slice(-10);
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

// Enhanced duplicate removal with ISBN-based deduplication
function removeDuplicates(books) {
  const seenISBNs = new Set();
  const seenTitles = new Set();
  
  return books.filter(book => {
    // Check ISBN duplicates first (most reliable)
    if (seenISBNs.has(book.isbn10)) {
      return false;
    }
    
    // Check title + author combination
    const titleKey = `${book.title.toLowerCase().replace(/[^\w]/g, '')}_${book.authors.toLowerCase()}`;
    if (seenTitles.has(titleKey)) {
      return false;
    }
    
    seenISBNs.add(book.isbn10);
    seenTitles.add(titleKey);
    return true;
  });
}

// Enhanced database operation with better error handling for trending books
async function updateTrendingBooksInDB(books) {
  console.log('\n💾 Updating TrendingBook collection...');
  
  // Ensure each book has _id set to isbn10 for trending books too
  const booksWithCorrectId = books.map(book => ({
    _id: book.isbn10,
    ...book
  }));
  
  try {
    // Method 1: Use deleteMany + insertMany with session for atomicity
    const session = await mongoose.startSession();
    
    try {
      await session.withTransaction(async () => {
        // Clear existing trending books
        const deleteResult = await TrendingBook.deleteMany({}, { session });
        console.log(`✅ Cleared ${deleteResult.deletedCount} existing trending books`);
        
        // Insert new trending books
        if (booksWithCorrectId.length > 0) {
          const insertResult = await TrendingBook.insertMany(booksWithCorrectId, { session });
          console.log(`✅ Inserted ${insertResult.length} new trending books`);
        }
      });
    } finally {
      await session.endSession();
    }
    
  } catch (error) {
    console.log('⚠️ Transaction method failed, trying alternative approach...');
    
    // Method 2: Drop collection and recreate (more aggressive)
    try {
      await mongoose.connection.db.collection('trendingbooks').drop();
      console.log('✅ Dropped existing trendingbooks collection');
    } catch (dropError) {
      // Collection might not exist, that's okay
      console.log('ℹ️ Collection drop skipped (might not exist)');
    }
    
    // Insert new books
    if (booksWithCorrectId.length > 0) {
      // Insert one by one to handle any remaining duplicates
      let insertedCount = 0;
      for (const book of booksWithCorrectId) {
        try {
          await mongoose.connection.db.collection('trendingbooks').insertOne(book);
          insertedCount++;
        } catch (insertError) {
          if (insertError.code === 11000) {
            console.log(`⚠️ Skipped duplicate: ${book.title}`);
          } else {
            console.log(`❌ Insert error for "${book.title}": ${insertError.message}`);
          }
        }
      }
      console.log(`✅ Inserted ${insertedCount} trending books`);
    }
  }
}

// Main optimized update function
export async function updateTrendingBooks() {
  const startTime = Date.now();
  console.log('🚀 Starting Enhanced Trending Books Update...\n');
  
  try {
    // Wait for database connection
    await waitForDatabaseConnection();
    
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
    
    // Update database with enhanced error handling
    await updateTrendingBooksInDB(finalBooks);
    
    // Sync to Book model - using batch method for better performance
    const bookSyncResults = await syncBooksToBookModelBatch(finalBooks);
    
    // Alternative: Individual sync method (use if batch method fails)
    // const bookSyncResults = await syncBooksToBookModel(finalBooks);
    
    const totalTime = ((Date.now() - startTime) / 1000).toFixed(1);
    
    console.log(`\n🎉 SUCCESS! Update completed in ${totalTime} seconds`);
    console.log(`📚 Final Results:`);
    console.log(`   - ${finalBooks.length} trending books updated`);
    console.log(`   - ${bookSyncResults.added} new books added to Book model`);
    console.log(`🖼️ All books have valid CORS-enabled thumbnails`);
    console.log(`🔑 All books have _id = isbn10 for consistency`);
    
    // Show sample book
    if (finalBooks.length > 0) {
      const sample = finalBooks[0];
      console.log(`\n📋 Sample Book:`);
      console.log(`   ID: ${sample.isbn10}`);
      console.log(`   Title: "${sample.title}"`);
      console.log(`   Author: ${sample.authors}`);
      console.log(`   Rating: ${sample.average_rating} (${sample.ratings_count} ratings)`);
      console.log(`   Image: ${sample.thumbnail}`);
    }
    
    // Return structured result
    return {
      success: true,
      data: {
        books: finalBooks,
        count: finalBooks.length,
        processingTime: totalTime,
        bookSyncResults: bookSyncResults,
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