import mongoose from 'mongoose';

const shelfSchema = new mongoose.Schema({
  _id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }, // Shelf ID = User ID

  books: [
    {
      isbn10:         { type: String, required: true },
      title:          { type: String, required: true },
      authors:        { type: String },
      categories:     { type: String },
      thumbnail:      { type: String },
      description:    { type: String },
      published_year: { type: Number },
      average_rating: { type: Number },
      ratings_count:  { type: Number }
    }
  ]
});

// Optional index if you want to sort user's shelf by recently published books
shelfSchema.index({ 'books.published_year': -1 });

const Shelf = mongoose.model('Shelf', shelfSchema);
export default Shelf;
