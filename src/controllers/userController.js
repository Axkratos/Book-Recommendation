import User from '../models/userModel.js';
import axios from 'axios';


// Get all users
export const getAllUsers = async (req, res) => {
  try {
    const users = await User.find();
    res.status(200).json({
      status: 'success',
      results: users.length,
      data: {
        users
      }
    });
  } catch (err) {
    res.status(500).json({
      status: 'error',
      message: err.message
    });
  }
};

// Get a single user by ID
export const getUser = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({
        status: 'fail',
        message: 'User not found'
      });
    }
    res.status(200).json({
      status: 'success',
      data: {
        user
      }
    });
  } catch (err) {
    res.status(500).json({
      status: 'error',
      message: err.message
    });
  }
};

// Update a user by ID
export const updateUser = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });
    if (!user) {
      return res.status(404).json({
        status: 'fail',
        message: 'User not found'
      });
    }
    res.status(200).json({
      status: 'success',
      data: {
        user
      }
    });
  } catch (err) {
    res.status(500).json({
      status: 'error',
      message: err.message
    });
  }
};

// Delete a user by ID
export const deleteUser = async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) {
      return res.status(404).json({
        status: 'fail',
        message: 'User not found'
      });
    }
    res.status(204).json({
      status: 'success',
      data: null
    });
  } catch (err) {
    res.status(500).json({
      status: 'error',
      message: err.message
    });
  }
};

const BIO_API_URL=process.env.FASTAPI_URL+'/user/bio';

export const getUserProfile = async (req, res, next) => {
  const userId = req.user.id;

  try {
    // 1) load user
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: 'fail',
        message: 'User not found.',
      });
    }

    // 2) if bio is empty, generate it
    if (!user.bio || user.bio.trim() === '') {
      const titles = (user.liked_books || []).slice(-5);
      if (titles.length) {
        const apiResp = await axios.post(BIO_API_URL, { titles });

        // unwrap string out of whatever the API returns
        let generatedBio;
        if (typeof apiResp.data === 'string') {
          generatedBio = apiResp.data;
        } else if (apiResp.data.user_bio && typeof apiResp.data.user_bio === 'string') {
          generatedBio = apiResp.data.user_bio;
        } else if (apiResp.data.bio && typeof apiResp.data.bio === 'string') {
          generatedBio = apiResp.data.bio;
        } else {
          // fallback to JSON if no string field found
          generatedBio = JSON.stringify(apiResp.data);
        }

        //  save to user
        user.bio = generatedBio;
        await user.save();
      }
    }

    // 3) return only the requested fields
    const { fullName, email, role, isEmailVerified, bio } = user;
    res.status(200).json({
      status: 'success',
      data: { fullName, email, role, isEmailVerified, bio },
    });

  } catch (err) {
    next(err);
  }
};

export const regenerateUserBio = async (req, res, next) => {
  const userId = req.user.id;

  try {
    // 1) load user
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: 'fail',
        message: 'User not found.',
      });
    }

    // 2) prepare last 5 liked books
    const titles = (user.liked_books || []).slice(-5);
    if (!titles.length) {
      return res.status(400).json({
        status: 'fail',
        message: 'Not enough liked books to generate bio.',
      });
    }

    // 3) hit the bio‐generation service
    const apiResp = await axios.post(BIO_API_URL, { titles });

    // 4) unwrap whatever comes back into a string
    let newBio;
    const data = apiResp.data;
    if (typeof data === 'string') {
      newBio = data;
    } else if (typeof data.user_bio === 'string') {
      newBio = data.user_bio;
    } else if (typeof data.bio === 'string') {
      newBio = data.bio;
    } else {
      newBio = JSON.stringify(data);
    }

    // 5) save and return
    user.bio = newBio;
    await user.save();

    const { fullName, email, role, isEmailVerified, bio } = user;
    res.status(200).json({
      status: 'success',
      data: { fullName, email, role, isEmailVerified, bio },
    });

  } catch (err) {
    next(err);
  }
};


export const updateFullName = async (req, res, next) => {
  const userId = req.user.id;
  const { fullName } = req.body;

  // 1) Validate input
  if (typeof fullName !== 'string' || !fullName.trim()) {
    return res.status(400).json({
      status: 'fail',
      message: 'A non‐empty string `fullName` is required.',
    });
  }

  try {
    // 2) Update fullName
    const updatedUser = await User.findByIdAndUpdate(
      userId,
      { fullName: fullName.trim() },
      {
        new: true,
        runValidators: true,
        select: 'fullName email role isEmailVerified bio'
      }
    );

    if (!updatedUser) {
      return res.status(404).json({
        status: 'fail',
        message: 'User not found.',
      });
    }

    // 3) Respond with updated profile
    const { fullName: name, email, role, isEmailVerified, bio } = updatedUser;
    res.status(200).json({
      status: 'success',
      data: { fullName: name, email, role, isEmailVerified, bio }
    });

  } catch (err) {
    next(err);
  }
};