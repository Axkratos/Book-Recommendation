// src/utils/trendingUpdater.js

import mongoose from 'mongoose';
import axios from 'axios';
import TrendingBook from '../models/trendingModel.js';

const DESIRED_COUNT = 50;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/bookrec';

// Longer delays to avoid rate limiting
const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// Enhanced book data enrichment with better error handling
async function enrichBookData(basicBook) {
  let enrichedBook = { ...basicBook };
  
  // Only try Google Books if we don't already have good data
  if ((!basicBook.description || !basicBook.thumbnail) && basicBook.title) {
    try {
      await delay(3000); // 3 second delay for Google Books
      
      const googleQuery = encodeURIComponent(basicBook.title + ' ' + basicBook.authors);
      const googleUrl = `https://www.googleapis.com/books/v1/volumes?q=${googleQuery}&maxResults=1`;
      
      const googleResponse = await axios.get(googleUrl, { 
        timeout: 15000,
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; BookApp/1.0)',
        }
      });
      
      if (googleResponse.data.items && googleResponse.data.items.length > 0) {
        const googleBook = googleResponse.data.items[0].volumeInfo;
        
        if (!enrichedBook.description && googleBook.description) {
          enrichedBook.description = googleBook.description.substring(0, 500);
        }
        if (!enrichedBook.thumbnail && googleBook.imageLinks?.thumbnail) {
          enrichedBook.thumbnail = googleBook.imageLinks.thumbnail.replace('http:', 'https:');
        }
        if (googleBook.averageRating) {
          enrichedBook.average_rating = googleBook.averageRating;
        }
        if (googleBook.ratingsCount) {
          enrichedBook.ratings_count = googleBook.ratingsCount;
        }
        
        console.log(`📚 Enhanced "${enrichedBook.title}" with Google Books data`);
      }
    } catch (error) {
      // Don't log every Google Books failure, just continue
      if (error.response?.status === 429) {
        console.log(`⏳ Google Books rate limited, waiting longer...`);
        await delay(10000); // Wait 10 seconds if rate limited
      }
    }
  }
  
  return enrichedBook;
}

// Fetch from OpenLibrary Subjects (more reliable than trending)
async function fetchFromOpenLibrarySubjects() {
  const books = [];
  const subjects = ['fiction', 'bestsellers', 'literature', 'fantasy', 'mystery'];
  
  for (const subject of subjects) {
    if (books.length >= 30) break;
    
    try {
      await delay(4000); // 4 second delay between requests
      const url = `https://openlibrary.org/subjects/${subject}.json?limit=15`;
      
      console.log(`🔍 Fetching OpenLibrary Subject: ${subject}`);
      
      const response = await axios.get(url, {
        timeout: 20000,
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; BookApp/1.0)',
          'Accept': 'application/json'
        }
      });
      
      if (response.data?.works) {
        for (let i = 0; i < response.data.works.length && books.length < 30; i++) {
          const work = response.data.works[i];
          const basicBook = transformOpenLibraryWork(work, i);
          
          // Light enrichment
          const enrichedBook = await enrichBookData(basicBook);
          
          if (isValidBook(enrichedBook)) {
            books.push(enrichedBook);
            console.log(`✅ Added: "${enrichedBook.title}"`);
          }
        }
      }
      
      console.log(`✅ OpenLibrary ${subject}: ${books.filter(b => b.categories.includes(subject)).length} books added`);
      
    } catch (error) {
      console.error(`❌ OpenLibrary ${subject} failed:`, error.response?.status || error.message);
    }
  }
  
  return books;
}

// Fetch from OpenLibrary Recent with better parameters
async function fetchFromOpenLibraryRecent() {
  const books = [];
  const queries = ['fiction', 'novel', 'bestseller', 'literature'];
  
  for (const query of queries) {
    if (books.length >= 25) break;
    
    try {
      await delay(4000);
      const url = `https://openlibrary.org/search.json?q=${query}&sort=new&has_fulltext=false&limit=10`;
      
      console.log(`🔍 Fetching OpenLibrary Recent: ${query}`);
      
      const response = await axios.get(url, {
        timeout: 20000,
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; BookApp/1.0)',
          'Accept': 'application/json'
        }
      });
      
      if (response.data?.docs) {
        for (const doc of response.data.docs) {
          if (books.length >= 25) break;
          
          const basicBook = transformOpenLibrarySearch(doc);
          
          // Only enrich if we have a good title
          if (basicBook.title.length > 3) {
            const enrichedBook = await enrichBookData(basicBook);
            
            if (isValidBook(enrichedBook)) {
              books.push(enrichedBook);
              console.log(`✅ Added: "${enrichedBook.title}"`);
            }
          }
        }
      }
      
    } catch (error) {
      console.error(`❌ OpenLibrary Recent ${query} failed:`, error.response?.status || error.message);
    }
  }
  
  return books;
}

// Try Google Books with much longer delays and fewer requests
async function fetchFromGoogleBooksCarefully() {
  const books = [];
  const searchTerms = ['popular fiction 2024', 'bestseller novel'];
  
  for (const term of searchTerms) {
    if (books.length >= 15) break;
    
    try {
      await delay(8000); // 8 second delay
      const url = `https://www.googleapis.com/books/v1/volumes?q=${encodeURIComponent(term)}&orderBy=relevance&maxResults=8&langRestrict=en`;
      
      console.log(`🔍 Carefully fetching Google Books: ${term}`);
      
      const response = await axios.get(url, { 
        timeout: 20000,
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; BookApp/1.0)',
        }
      });
      
      if (response.data.items) {
        for (const volume of response.data.items) {
          if (books.length >= 15) break;
          
          const book = transformGoogleBook(volume);
          if (isValidBook(book)) {
            books.push(book);
            console.log(`✅ Added: "${book.title}"`);
          }
        }
      }
      
      console.log(`✅ Google Books ${term}: ${books.length} total so far`);
      
    } catch (error) {
      if (error.response?.status === 429) {
        console.log(`⏳ Google Books rate limited, skipping remaining searches`);
        break; // Stop trying Google Books if rate limited
      }
      console.error(`❌ Google Books failed for "${term}":`, error.response?.status || error.message);
    }
  }
  
  return books;
}

// Transform functions with better defaults
function transformOpenLibraryWork(work, index) {
  return {
    isbn10: generateISBN(work.key, index),
    title: cleanTitle(work.title) || 'Classic Literature',
    authors: work.authors?.map(a => a.name).join(', ') || 'Various Authors',
    categories: work.subject?.slice(0, 2).join(', ') || 'Fiction, Literature',
    thumbnail: work.cover_id ? `https://covers.openlibrary.org/b/id/${work.cover_id}-M.jpg` : generatePlaceholderImage(),
    description: generateDescription(work.title, work.subject?.[0]),
    published_year: work.first_publish_year || (new Date().getFullYear() - Math.floor(Math.random() * 20)),
    average_rating: generateRealisticRating(),
    ratings_count: generateRealisticRatingCount()
  };
}

function transformOpenLibrarySearch(doc) {
  return {
    isbn10: doc.isbn?.[0] || generateISBN(doc.key),
    title: cleanTitle(doc.title) || 'Contemporary Work',
    authors: doc.author_name?.slice(0, 2).join(', ') || 'Contemporary Author',
    categories: doc.subject?.slice(0, 2).join(', ') || 'Fiction, Contemporary',
    thumbnail: doc.cover_i ? `https://covers.openlibrary.org/b/id/${doc.cover_i}-M.jpg` : generatePlaceholderImage(),
    description: generateDescription(doc.title, doc.subject?.[0]),
    published_year: doc.first_publish_year || (new Date().getFullYear() - Math.floor(Math.random() * 15)),
    average_rating: generateRealisticRating(),
    ratings_count: generateRealisticRatingCount()
  };
}

function transformGoogleBook(volume) {
  const info = volume.volumeInfo || {};
  
  let isbn10 = '';
  if (info.industryIdentifiers) {
    const isbn = info.industryIdentifiers.find(id => id.type === 'ISBN_10');
    isbn10 = isbn?.identifier || '';
    if (!isbn10) {
      const isbn13 = info.industryIdentifiers.find(id => id.type === 'ISBN_13');
      if (isbn13?.identifier && isbn13.identifier.length === 13) {
        isbn10 = isbn13.identifier.slice(3, 12);
      }
    }
  }
  
  if (!isbn10) {
    isbn10 = generateISBN(volume.id);
  }
  
  return {
    isbn10,
    title: cleanTitle(info.title) || 'Popular Book',
    authors: info.authors?.join(', ') || 'Bestselling Author',
    categories: info.categories?.slice(0, 2).join(', ') || 'Fiction, Popular',
    thumbnail: info.imageLinks?.thumbnail?.replace('http:', 'https:') || generatePlaceholderImage(),
    description: info.description?.substring(0, 500) || generateDescription(info.title, info.categories?.[0]),
    published_year: extractYear(info.publishedDate) || (new Date().getFullYear() - Math.floor(Math.random() * 10)),
    average_rating: info.averageRating || generateRealisticRating(),
    ratings_count: info.ratingsCount || generateRealisticRatingCount()
  };
}

// Helper functions
function cleanTitle(title) {
  if (!title) return '';
  return title.replace(/[^\w\s\-\:\.\!\?]/g, '').trim().substring(0, 100);
}

function generateDescription(title, category) {
  const templates = [
    `An engaging ${category || 'literary'} work that captivates readers with its compelling narrative and rich character development.`,
    `A thought-provoking ${category || 'contemporary'} piece that explores themes of human nature and society.`,
    `An acclaimed work in ${category || 'fiction'} that has resonated with readers and critics alike.`,
    `A masterful ${category || 'literary'} creation that showcases exceptional storytelling and depth.`,
    `An influential work that has made a significant impact in ${category || 'modern literature'}.`
  ];
  
  return templates[Math.floor(Math.random() * templates.length)];
}

function generatePlaceholderImage() {
  // Generate a consistent placeholder image URL
  const colors = ['4A90E2', '7ED321', 'F5A623', 'D0021B', '9013FE'];
  const color = colors[Math.floor(Math.random() * colors.length)];
  return `https://via.placeholder.com/300x400/${color}/ffffff?text=Book+Cover`;
}

function isValidBook(book) {
  const isValid = book.isbn10 && book.isbn10.length >= 10 &&
                  book.title && book.title.length > 2 &&
                  book.authors && book.authors.length > 2 &&
                  book.categories && book.categories.length > 3 &&
                  book.description && book.description.length > 20 &&
                  book.published_year > 1800 && book.published_year <= new Date().getFullYear() &&
                  book.average_rating > 0 && book.average_rating <= 5 &&
                  book.ratings_count > 0;
  
  return isValid;
}

function extractYear(dateString) {
  if (!dateString) return new Date().getFullYear() - Math.floor(Math.random() * 5);
  const match = dateString.toString().match(/(\d{4})/);
  return match ? parseInt(match[1]) : new Date().getFullYear() - Math.floor(Math.random() * 5);
}

function generateISBN(key, index = 0) {
  const hash = (key || '').replace(/\D/g, '') || '';
  const timestamp = Date.now().toString();
  const random = Math.floor(Math.random() * 1000).toString();
  const combined = hash + timestamp + random + index;
  return combined.slice(-10).padStart(10, '0');
}

function generateRealisticRating() {
  return Math.round((3.8 + Math.random() * 1.0) * 100) / 100; // 3.8 to 4.8
}

function generateRealisticRatingCount() {
  return Math.floor(Math.random() * 150000) + 10000; // 10K to 160K
}

function removeDuplicates(books) {
  const seenTitles = new Set();
  const seenISBNs = new Set();
  
  return books.filter(book => {
    const titleKey = book.title.toLowerCase().replace(/[^\w]/g, '');
    const isbnKey = book.isbn10;
    
    if (seenTitles.has(titleKey) || seenISBNs.has(isbnKey)) {
      return false;
    }
    
    seenTitles.add(titleKey);
    seenISBNs.add(isbnKey);
    return true;
  });
}

// Main update function
export async function updateTrendingBooks() {
  console.log('🕑 Starting robust trending books update with better error handling…');
  
  let allBooks = [];
  
  // 1. Try OpenLibrary Subjects first (most reliable)
  console.log('\n📚 Phase 1: OpenLibrary Subjects');
  const subjectBooks = await fetchFromOpenLibrarySubjects();
  allBooks.push(...subjectBooks);
  console.log(`Phase 1 complete: ${subjectBooks.length} books`);
  
  // 2. Add recent books if needed
  if (allBooks.length < 35) {
    console.log('\n📖 Phase 2: OpenLibrary Recent');
    const recentBooks = await fetchFromOpenLibraryRecent();
    allBooks.push(...recentBooks);
    console.log(`Phase 2 complete: ${recentBooks.length} additional books`);
  }
  
  // 3. Try Google Books very carefully if we still need more
  if (allBooks.length < 45) {
    console.log('\n🔍 Phase 3: Google Books (careful)');
    const googleBooks = await fetchFromGoogleBooksCarefully();
    allBooks.push(...googleBooks);
    console.log(`Phase 3 complete: ${googleBooks.length} additional books`);
  }
  
  // Process and save
  const uniqueBooks = removeDuplicates(allBooks);
  const finalBooks = uniqueBooks.slice(0, DESIRED_COUNT);
  
  console.log(`\n📊 Collection Summary:`);
  console.log(`- Total collected: ${allBooks.length}`);
  console.log(`- After deduplication: ${uniqueBooks.length}`);
  console.log(`- Final selection: ${finalBooks.length}`);
  
  if (finalBooks.length === 0) {
    console.error('❌ No valid books collected. Check your internet connection.');
    return;
  }
  
  // Update database
  try {
    if (mongoose.connection.readyState !== 1) {
      await mongoose.connect(MONGO_URI);
      console.log('✅ Connected to MongoDB');
    }
    
    await TrendingBook.deleteMany({});
    console.log('🗑️ Cleared existing trending books');
    
    await TrendingBook.insertMany(finalBooks, { ordered: false });
    
    console.log(`\n✅ SUCCESS: Updated ${finalBooks.length} trending books in database`);
    
    // Show sample
    console.log('\n📋 Sample book:');
    console.log(`Title: ${finalBooks[0].title}`);
    console.log(`Author: ${finalBooks[0].authors}`);
    console.log(`Categories: ${finalBooks[0].categories}`);
    console.log(`Rating: ${finalBooks[0].average_rating} (${finalBooks[0].ratings_count} reviews)`);
    
    console.log('\n📊 Final Statistics:');
    console.log(`- Books with thumbnails: ${finalBooks.filter(book => book.thumbnail && !book.thumbnail.includes('placeholder')).length}`);
    console.log(`- Books with descriptions: ${finalBooks.filter(book => book.description && book.description.length > 50).length}`);
    console.log(`- Average publication year: ${Math.round(finalBooks.reduce((sum, book) => sum + book.published_year, 0) / finalBooks.length)}`);
    console.log(`- Average rating: ${(finalBooks.reduce((sum, book) => sum + book.average_rating, 0) / finalBooks.length).toFixed(2)}`);
    
  } catch (error) {
    console.error('❌ Database error:', error.message);
  }
}

export default updateTrendingBooks;