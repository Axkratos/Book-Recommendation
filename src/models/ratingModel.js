// models/Rating.js
import mongoose from 'mongoose';

const ratingSchema = new mongoose.Schema({
  'User-ID': { type: mongoose.Schema.Types.Mixed, required: true },

  'ISBN': { type: String, required: true },
  'Book-Rating': { type: Number, required: true, min: 0, max: 10 }
}, {
  timestamps: true 
});
export default mongoose.model('Rating', ratingSchema);
