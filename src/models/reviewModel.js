import mongoose from 'mongoose';

const reviewSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    userName: {
      type: String,
      required: true
    },
    isbn: {
      type: String,
      ref: 'Book',
      required: true
    },
    review: {
      type: String,
      required: true
    }
  },
  {
    timestamps: true // adds createdAt and updatedAt
  }
);

// Optional indexes for faster querying
reviewSchema.index({ user: 1, isbn: 1 }, { unique: true }); // one review per user per book
reviewSchema.index({ isbn: 1 });
reviewSchema.index({ userName: "text", review: "text" });

const Review = mongoose.model('Review', reviewSchema);
export default Review;
