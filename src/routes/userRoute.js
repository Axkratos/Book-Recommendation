import express from 'express';
import { getAllUsers, getUser, updateUser } from '../controllers/userController.js';
import { getTrendingBooks,getBooks,getBookByISBN } from '../controllers/bookController.js';
const router = express.Router();


 

router.get('/trending', getTrendingBooks);
router.get('/books', getBooks);
router.get('/books/:isbn', getBookByISBN);
//profile Completion


export default router;
