import Forum from '../models/forumModel.js';
import mongoose from 'mongoose';


export const createForum = async (req, res) => {
  const userId = req.user.id;
  const { ISBN, bookTitle, discussionTitle, discussionBody } = req.body;

  try {
    const newForum = await Forum.create({
      userId,
      ISBN,
      bookTitle,
      discussionTitle,
      discussionBody
    });

    res.status(201).json({
      status: 'success',
      data: newForum
    });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
};

export const updateForum = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const forum = await Forum.findById(id);

    if (!forum) {
      return res.status(404).json({ status: 'fail', message: 'Forum not found' });
    }

    if (forum.userId.toString() !== userId) {
      return res.status(403).json({ status: 'fail', message: 'Unauthorized to update this forum' });
    }

    const { ISBN, bookTitle, discussionTitle, discussionBody } = req.body;

    if (ISBN) forum.ISBN = ISBN;
    if (bookTitle) forum.bookTitle = bookTitle;
    if (discussionTitle) forum.discussionTitle = discussionTitle;
    if (discussionBody) forum.discussionBody = discussionBody;

    await forum.save();

    res.status(200).json({ status: 'success', data: forum });

  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
};

export const getAllForums = async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const skip = (page - 1) * limit;

  try {
    const forums = await Forum.find()
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate('userId', 'name');

    const total = await Forum.countDocuments();

    res.status(200).json({
      status: 'success',
      results: forums.length,
      total,
      page,
      totalPages: Math.ceil(total / limit),
      data: forums
    });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
};

// 3. Get single forum by ID
export const getForumById = async (req, res) => {
  const { id } = req.params;

  try {
    const forum = await Forum.findById(id).populate('userId', 'name');

    if (!forum) {
      return res.status(404).json({ status: 'fail', message: 'Forum not found' });
    }

    res.status(200).json({ status: 'success', data: forum });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
};

//get users forum
export const getUserForums = async (req, res) => {
  try {
    const userId = req.user.id;

    // Pagination params, default page 1, limit 10
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    // Count total forums by user
    const totalForums = await Forum.countDocuments({ userId });

    // Fetch user forums with pagination, sorted by newest first
    const forums = await Forum.find({ userId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    res.status(200).json({
      status: 'success',
      results: forums.length,
      totalForums,
      page,
      totalPages: Math.ceil(totalForums / limit),
      data: forums
    });

  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
};

//like forum
export const toggleLikeForum = async (req, res) => {
  const forumId = req.params.id;
  const userId = req.user.id;

  if (!mongoose.Types.ObjectId.isValid(forumId)) {
    return res.status(400).json({ status: 'fail', message: 'Invalid forum ID' });
  }

  try {
    const forum = await Forum.findById(forumId);
    if (!forum) {
      return res.status(404).json({ status: 'fail', message: 'Forum not found' });
    }

    const alreadyLiked = forum.likes.includes(userId);

    if (alreadyLiked) {
      forum.likes.pull(userId);
    } else {
      forum.likes.push(userId);
    }

    await forum.save();

    res.status(200).json({
      status: 'success',
      liked: !alreadyLiked,
      likeCount: forum.likes.length
    });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
};

// 5. Check if user already liked a forum
export const hasLikedForum = async (req, res) => {
  const forumId = req.params.id;
  const userId = req.user.id;

  if (!mongoose.Types.ObjectId.isValid(forumId)) {
    return res.status(400).json({ status: 'fail', message: 'Invalid forum ID' });
  }

  try {
    const forum = await Forum.findById(forumId);
    if (!forum) {
      return res.status(404).json({ status: 'fail', message: 'Forum not found' });
    }

    const liked = forum.likes.includes(userId);

    res.status(200).json({ status: 'success', liked });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
};
// 6. Delete forum
export const deleteForum = async (req, res) => {
  const forumId = req.params.id;
  const userId = req.user.id;

  try {
    const forum = await Forum.findById(forumId);

    if (!forum) {
      return res.status(404).json({ status: 'fail', message: 'Forum not found' });
    }

    if (forum.userId.toString() !== userId) {
      return res.status(403).json({ status: 'fail', message: 'Unauthorized to delete this forum' });
    }

    await Forum.findByIdAndDelete(forumId);

    res.status(200).json({ status: 'success', message: 'Forum deleted successfully' });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
};