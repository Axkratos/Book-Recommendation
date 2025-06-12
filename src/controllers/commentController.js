import Comment from '../models/commentModel.js';
import Forum from '../models/forumModel.js';
// Create a new comment for a forum
export const createComment = async (req, res) => {
  try {
    const { isbn, forumId, comment } = req.body;
    const userId = req.user.id;

    const newComment = await Comment.create({ isbn, forumId, userId, comment });

    // Increase commentCount for the forum
    await Forum.findByIdAndUpdate(forumId, { $inc: { commentCount: 1 } });

    res.status(201).json({ status: 'success', data: newComment });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
};
export const getCommentsByForum = async (req, res) => {
  try {
    const forumId = req.params.id;
    const currentUserId = req.user?.id;
    const comments = await Comment.find({ forumId }).populate('userId', 'fullName');
   // Add "commented" flag: true if this comment belongs to current user
    const data = comments.map(c => ({
      _id: c._id,
      isbn: c.isbn,
      forumId: c.forumId,
      user: c.userId,
      comment: c.comment,
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
      commented: currentUserId ? c.userId._id.toString() === currentUserId : false
    }));

    res.status(200).json({ status: 'success', data });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
};

// Get all comments by a single user
export const getCommentsByUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const comments = await Comment.find({ userId });
    res.status(200).json({ status: 'success', data: comments });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
};

// Check if a user has commented on a specific forum
export const hasUserCommented = async (req, res) => {
  try {
    const { forumId } = req.params;
    const userId = req.user.id;
    const exists = await Comment.exists({ forumId, userId });
    res.status(200).json({ status: 'success', commented: Boolean(exists) });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
};

// Update a comment (only by owner)
export const updateComment = async (req, res) => {
  try {
    const commentId = req.params.id;
    const userId = req.user.id;
    const { comment } = req.body;
    console.log(comment)

    // Authorization: only the comment owner can update
    const existing = await Comment.findById(commentId);
    if (!existing) {
      return res.status(404).json({ status: 'fail', message: 'Comment not found.' });
    }
    if (existing.userId.toString() !== userId) {
      return res.status(403).json({ status: 'fail', message: 'Not authorized to update this comment.' });
    }

    const updated = await Comment.findByIdAndUpdate(
      commentId,
      { comment },
      { new: true, runValidators: true }
    );

    res.status(200).json({ status: 'success', data: updated });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
};

// Delete a comment (only by owner)
export const deleteComment = async (req, res) => {
  try {
    const commentId  = req.params.id;
    const userId = req.user.id;

    const existing = await Comment.findById(commentId);
    if (!existing) {
      return res.status(404).json({ status: 'fail', message: 'Comment not found.' });
    }
    if (existing.userId.toString() !== userId) {
      return res.status(403).json({ status: 'fail', message: 'Not authorized to delete this comment.' });
    }

    // Decrease commentCount for the forum
    await Forum.findByIdAndUpdate(existing.forumId, { $inc: { commentCount: -1 } });

    await Comment.findByIdAndDelete(commentId);
    res.status(204).send();
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
};
