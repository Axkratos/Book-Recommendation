// utils/bookUpload.js
import fs from 'fs';
import path, { dirname } from 'path';
import { fileURLToPath } from 'url';
import csv from 'csv-parser';
import mongoose from 'mongoose';
import Book from '../models/bookModel.js';  // adjust if your path differs

// MongoDB connection string (env or default)
const MONGO_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/your_db_name';
//dont forgot to give dbname here hai bookrec

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

async function connectDB() {
  try {
    await mongoose.connect(MONGO_URI);
    console.log('✅ MongoDB connected');
  } catch (err) {
    console.error('❌ MongoDB connection error:', err.message);
    process.exit(1);
  }
}

async function importBooks() {
  const books = [];
  // Resolve CSV path relative to this script
  const csvPath = path.resolve(__dirname, 'final_books.csv');

  // Check file existence
  if (!fs.existsSync(csvPath)) {
    console.error(`❌ CSV file not found at ${csvPath}`);
    process.exit(1);
  }

  const readStream = fs.createReadStream(csvPath)
    .on('error', err => {
      console.error('❌ Failed to open CSV:', err.message);
      process.exit(1);
    })
    .pipe(csv())
    .on('data', (row) => {
      books.push({
        _id:             row.isbn10,
        isbn10:          row.isbn10,
        title:           row.title,
        authors:         row.authors,
        categories:      row.categories,
        thumbnail:       row.thumbnail,
        description:     row.description,
        published_year:  Number(row.published_year) || undefined,
        average_rating:  Number(row.average_rating) || undefined,
        ratings_count:   Number(row.ratings_count) || undefined
      });
    });

  readStream.on('end', async () => {
    try {
      await Book.insertMany(books, { ordered: false });
      console.log(`✅ Inserted ${books.length} books`);
    } catch (err) {
      console.error('⚠️ Error inserting books (duplicates skipped):', err.message);
    } finally {
      await mongoose.disconnect();
      console.log('🔌 MongoDB disconnected');
    }
  });
}

// (async () => {
//   await connectDB();
//   await importBooks();
// })();
