// comment.model.js
import mongoose from 'mongoose';

const commentSchema = new mongoose.Schema({
  isbn: {
    type: String,
    required: true,
    ref: 'Book'
  },
  forumId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Forum',
    required: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  comment: {
    type: String,
    required: true,
    trim: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// ensure updatedAt is current
commentSchema.pre('findOneAndUpdate', function(next) {
  this.set({ updatedAt: Date.now() });
  next();
});

const Comment = mongoose.model('Comment', commentSchema);
export default Comment;