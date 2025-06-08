import express from 'express';
import { getAllUsers, getUser, updateUser } from '../controllers/userController.js';
import { getTrendingBooks } from '../controllers/bookController.js';
const router = express.Router();


 

router.get('/trending', getTrendingBooks);

//profile Completion


export default router;
