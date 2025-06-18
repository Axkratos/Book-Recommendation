import mongoose from "mongoose";

const bookSchema = new mongoose.Schema({
  _id: { 
    type: String,     // Explicitly set as String type
    required: true    // Make it required
  },
  isbn10: { type: String, required: true, unique: true },
  title: { type: String, required: true },
  authors: { type: String }, // comma-separated if multiple
  categories: { type: String }, // comma-separated if multiple
  thumbnail: { type: String },
  description: { type: String },
  published_year: { type: Number },
  average_rating: { type: Number },
  ratings_count: { type: Number },
},
{
  _id: false  // CRITICAL: This tells Mongoose not to auto-generate _id fields
});

// Ensure _id is set from isbn10 before saving
bookSchema.pre("save", function (next) {
  if (!this._id) {
    this._id = this.isbn10;
  }
  next();
});

// Optional index for sorting/querying by year
bookSchema.index({ published_year: -1 });

// Optional index for categories if you want to filter by them
bookSchema.index({ categories: "text" }); // Full-text search index for categories

bookSchema.index({
  title: "text",
  authors: "text", 
  description: "text"
}, {
  weights: {
    title: 10,      // Title matches are most important
    authors: 5,     // Author matches are moderately important  
    description: 1  // Description matches are least important
  },
  name: "book_text_search"
});

// Individual field indexes for specific searches
bookSchema.index({ title: 1 });         // For title-specific searches
bookSchema.index({ authors: 1 });       // For author-specific searches
bookSchema.index({ average_rating: -1 }); // For rating-based filtering and sorting

// Compound indexes for common query patterns
bookSchema.index({ average_rating: -1, ratings_count: -1 }); // For quality-based sorting
bookSchema.index({ categories: 1, average_rating: -1 });     // For category + rating filtering
bookSchema.index({ published_year: -1, average_rating: -1 }); // For year + rating sorting

const Book = mongoose.model("Book", bookSchema);
export default Book;
