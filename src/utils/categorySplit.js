import mongoose from 'mongoose';
import Book from '../models/bookModel.js';

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/your_db_name';

async function connectDB() {
  await mongoose.connect(MONGO_URI);
  console.log('🚀 Connected to MongoDB');
}

async function migrateCategories() {
  const books = await Book.find();

  for (const book of books) {
    const raw = book.categories;

    if (typeof raw === 'string') {
      const cleaned = raw
        .split(/[,;&]+/i)                     // split by , ; & and similar
        .map(cat => cat.trim().toLowerCase()) // trim and lowercase
        .filter(cat => cat.length > 0);       // remove empty entries

      book.categories = [...new Set(cleaned)]; // remove duplicates
      await book.save();
    }
  }

  console.log('✅ Categories migration completed');
}

// (async () => {
//   try {
//     await connectDB();
//     await migrateCategories();
//     mongoose.disconnect();
//   } catch (err) {
//     console.error('❌ Migration error:', err);
//     mongoose.disconnect();
//   }
// })();
