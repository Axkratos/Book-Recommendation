import mongoose from 'mongoose';

const forumSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
    ISBN: {
  type: String, // changed from Number to String
  required: true
},

  bookTitle: {
    type: String,
    required: true
  },
  discussionTitle: {
    type: String,
    required: true
  },
  discussionBody: {
    type: String,
    required: true
  },
  
  createdAt: {
    type: Date,
    default: Date.now
  },
  likes: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  likeCount: {
    type: Number,
    default: 0
  }
});

// Auto-update likeCount before save
forumSchema.pre('save', function (next) {
  this.likeCount = this.likes.length;
  next();
});

const Forum = mongoose.model('Forum', forumSchema);
export default Forum;
