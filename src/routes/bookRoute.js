import express from 'express';

import { protect, restrictTo } from '../middlewares/authMiddleware.js';
import { likeBooks,getLLMRecommendations,getTrendingBooks,addRating ,getItemBasedRecommendations,getUserBasedRecommendations,getItemBasedRecommendationsByTitle,getRating,checkBookSelected} from '../controllers/bookController.js';
import { addBookToShelf,getShelfBooks,removeBookFromShelf,checkBookInShelf } from '../controllers/shelfController.js';
import { createForum,deleteForum,toggleLikeForum,hasLikedForum,updateForum ,getUserForums} from '../controllers/forumController.js';
import { createComment,getCommentsByForum,getCommentsByUser,hasUserCommented,updateComment,deleteComment } from '../controllers/commentController.js';
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
router.get('/forum/user', getUserForums);
router.patch('/forum/:id', updateForum);
router.delete('/forum/:id', deleteForum);
router.post('/forum/like/:id', toggleLikeForum);
router.get('/forum/like/status/:id', hasLikedForum);

//check if book is selected
router.get('/checkbook', checkBookSelected);


//comment
router.post('/comment', createComment);
router.get('/comment/forum/:id', getCommentsByForum);
router.get('/comment/user/:userId', getCommentsByUser);
router.get('/comment/has/:forumId', hasUserCommented);
router.patch('/comment/:id', updateComment);
router.delete('/comment/:id', deleteComment);

export default router;