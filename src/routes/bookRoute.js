import express from 'express';

import { protect, restrictTo } from '../middlewares/authMiddleware.js';
import { likeBooks,getLLMRecommendations,getTrendingBooks } from '../controllers/bookController.js';


const router = express.Router();

router.use(protect);
router.use(restrictTo('user'));


router.post('/like', likeBooks);
router.post('/recommend/llm', getLLMRecommendations);


export default router;