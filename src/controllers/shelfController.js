// controllers/shelfController.js

import Shelf from '../models/shelfModel.js';


export const addBookToShelf = async (req, res) => {
  const userId = req.user.id;
  const book = req.body;

  // Basic validation
  if (
    !book ||
    typeof book.isbn10 !== 'string' ||
    typeof book.title !== 'string'
  ) {
    return res.status(400).json({
      status: 'fail',
      message: 'Request body must include at least { isbn10: String, title: String }'
    });
  }

  try {
    // 1. Load (or create) the shelf
    let shelf = await Shelf.findById(userId);
    if (!shelf) {
      shelf = await Shelf.create({ _id: userId, books: [] });
    }

    // 2. Check for existing ISBN
    const exists = shelf.books.some(b => b.isbn10 === book.isbn10);
    if (exists) {
      return res.status(400).json({
        status: 'fail',
        message: `Book with ISBN10 ${book.isbn10} is already on your shelf.`
      });
    }

    // 3. Push and save
    shelf.books.push(book);
    await shelf.save();

    res.status(200).json({
      status: 'success',
      data: { shelf: shelf.books }
    });
  } catch (err) {
    res.status(500).json({
      status: 'error',
      message: err.message
    });
  }
};

/**
 * Get all books on the authenticated user's shelf.
 */
export const getShelfBooks = async (req, res) => {
  const userId = req.user.id;

  try {
    const shelf = await Shelf.findById(userId);
    res.status(200).json({
      status: 'success',
      data: { shelf: shelf ? shelf.books : [] }
    });
  } catch (err) {
    res.status(500).json({
      status: 'error',
      message: err.message
    });
  }
};

/**
 * Remove a book (by ISBN10) from the authenticated user's shelf.
 * DELETE /shelf/:isbn10
 */
export const removeBookFromShelf = async (req, res) => {
  const userId = req.user.id;
  const { isbn10 } = req.params;

  try {
    const shelf = await Shelf.findByIdAndUpdate(
      userId,
      { $pull: { books: { isbn10 } } },
      { new: true }
    );

    if (!shelf) {
      return res.status(404).json({
        status: 'fail',
        message: 'Shelf not found.'
      });
    }

    res.status(200).json({
      status: 'success',
      data: { shelf: shelf.books }
    });
  } catch (err) {
    res.status(500).json({
      status: 'error',
      message: err.message
    });
  }
};

export const checkBookInShelf = async (req, res) => {
  const userId = req.user.id;
  const { isbn10 } = req.params;

  try {
    // Load the shelf (if it exists)
    const shelf = await Shelf.findById(userId);
    if (shelf && shelf.books.some(book => book.isbn10 === isbn10)) {
      return res.status(200).json({ status: 'present' });
    }

    // Either no shelf or book not found
    return res.status(200).json({ status: 'absent' });
  } catch (err) {
    return res.status(500).json({
      status: 'error',
      message: err.message
    });
  }
};
