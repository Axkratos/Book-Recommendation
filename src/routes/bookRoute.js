import express from 'express';

import { protect, restrictTo } from '../middlewares/authMiddleware.js';
import { likeBooks,getLLMRecommendations,getTrendingBooks,addRating ,getItemBasedRecommendations,getUserBasedRecommendations,getItemBasedRecommendationsByTitle,getRating} from '../controllers/bookController.js';
import { addBookToShelf,getShelfBooks,removeBookFromShelf,checkBookInShelf } from '../controllers/shelfController.js';
import { createForum,deleteForum,toggleLikeForum,hasLikedForum,updateForum } from '../controllers/forumController.js';
const router = express.Router();

router.use(protect);
router.use(restrictTo('user'));


router.post('/like', likeBooks);
router.post('/recommend/llm', getLLMRecommendations);

router.post('/shelf/add', addBookToShelf);
router.get('/shelf', getShelfBooks);
router.delete('/shelf/:isbn10', removeBookFromShelf);
router.get('/shelf/check/:isbn10', checkBookInShelf);


//add rating to a book
router.post('/rating', addRating);
router.get('/rating/:isbn10', getRating);
router.get('/recommend/item', getItemBasedRecommendations);
router.get('/recommend/user', getUserBasedRecommendations);
router.get('/recommend/item/:title', getItemBasedRecommendationsByTitle);

//forum
router.post('/forum', createForum);
router.patch('/forum/:id', updateForum);
router.delete('/forum/:id', deleteForum);
router.post('/forum/like/:id', toggleLikeForum);
router.get('/forum/like/status/:id', hasLikedForum);


export default router;