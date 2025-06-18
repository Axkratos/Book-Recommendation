// report.model.js
import mongoose from 'mongoose';

const reportSchema = new mongoose.Schema({
  type: {
    type: String,
    enum: ['comment', 'review', 'forum'],
    required: true
  },
  targetId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true
  },
  // optional: you could enforce ref per type via custom validation
  content: {
    type: String,
    required: true,
    trim: true
  },
  reporter: {
    // who submitted the report
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  createdBy: {
    // author/owner of the reported object
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
}, {
  timestamps: true
});

const Report = mongoose.model('Report', reportSchema);
export default Report;
