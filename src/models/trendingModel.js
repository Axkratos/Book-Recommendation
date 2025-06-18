
import mongoose from 'mongoose';

const trendingBookSchema = new mongoose.Schema({
  isbn10:         { type: String, required: true, unique: true },
  title:          { type: String, required: true },
  authors:        { type: String },        // comma-separated if multiple
  categories:     { type: String },        // comma-separated if multiple
  thumbnail:      { type: String },
  description:    { type: String },
  published_year: { type: Number },
  average_rating: { type: Number },
  ratings_count:  { type: Number }
},
{
  _id: false  // CRITICAL: This tells Mongoose not to auto-generate _id fields
});

// Ensure we can query “latest 50” in insertion order if needed
trendingBookSchema.index({ published_year: -1 });

const TrendingBook = mongoose.model('TrendingBook', trendingBookSchema);
export default TrendingBook;
