import express from 'express';
import { getAllUsers, getUser, updateUser } from '../controllers/userController.js';
import { getTrendingBooks,getBooks,getBookByISBN } from '../controllers/bookController.js';
import { getAllForums,getForumById } from '../controllers/forumController.js';
const router = express.Router();


 

router.get('/trending', getTrendingBooks);
router.get('/books', getBooks);
router.get('/books/:isbn', getBookByISBN);
//profile Completion

router.get('/forums', getAllForums);
router.get('/forums/:id', getForumById);


export default router;
