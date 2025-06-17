
from fastapi import APIRouter, HTTPException, BackgroundTasks
from typing import List
import logging
from app.controllers.recommender import (
    models, BookRec, ItemRecRequest, UserRecRequest, 
    retrain_hybrid, get_content_recommendations, get_collaborative_recommendations,
    find_book_by_title,Query, Book, recommend_books_logic,fold_in_user
)
from app.models.database import get_user_ratings,load_all_books,load_user_ratings

# Setup logging
logger = logging.getLogger(__name__)

router = APIRouter()

@router.post("/retrain")
async def retrain_models(background_tasks: BackgroundTasks):
    """Trigger model retraining"""
    background_tasks.add_task(retrain_hybrid)
    return {"detail": "Model retraining started in background"}

@router.post("/recommend/item", response_model=List[BookRec])
async def recommend_items(request: ItemRecRequest):
    """Get hybrid item-based recommendations for multiple books with balanced distribution"""
    if not models.is_loaded():
        raise HTTPException(status_code=503, detail="Models not loaded. Please retrain first.")
    
    try:
        found_books = []
        not_found_books = []
        
        # First, validate all input books and get their ISBNs
        for title in request.book_titles:
            target_isbn = find_book_by_title(title)
            if target_isbn:
                found_books.append((title, target_isbn))
            else:
                not_found_books.append(title)
        
        if not found_books:
            raise HTTPException(
                status_code=404, 
                detail=f"None of the requested books were found: {', '.join(not_found_books)}"
            )
        
        # Calculate recommendations per book (balanced distribution)
        num_found_books = len(found_books)
        recs_per_book = max(1, request.limit // num_found_books)
        extra_recs = request.limit % num_found_books
        
        # Collect recommendations from all books with scoring
        book_recommendations = []
        
        for i, (title, isbn) in enumerate(found_books):
            # Calculate limit for this book (distribute extra recommendations)
            current_limit = recs_per_book + (1 if i < extra_recs else 0)
            
            # Get collaborative and content-based recommendations
            collab_recs = get_collaborative_recommendations(isbn, current_limit * 2)  # Get more to have options
            content_recs = get_content_recommendations(isbn, current_limit * 2)
            
            # Score and combine recommendations
            # Collaborative filtering gets higher priority (score 2), content-based gets score 1
            for j, rec_isbn in enumerate(collab_recs):
                if rec_isbn in models.all_books:
                    score = 2.0 - (j * 0.1)  # Decreasing score based on rank
                    book_recommendations.append({
                        'isbn': rec_isbn,
                        'source_book': title,
                        'score': score,
                        'method': 'collaborative'
                    })
            
            for j, rec_isbn in enumerate(content_recs):
                if rec_isbn in models.all_books:
                    score = 1.0 - (j * 0.05)  # Lower base score, slower decay
                    book_recommendations.append({
                        'isbn': rec_isbn,
                        'source_book': title,
                        'score': score,
                        'method': 'content'
                    })
        
        # Remove duplicates and aggregate scores
        isbn_scores = {}
        isbn_sources = {}
        
        for rec in book_recommendations:
            isbn = rec['isbn']
            if isbn in isbn_scores:
                # Boost score for books recommended by multiple sources
                isbn_scores[isbn] += rec['score'] * 0.5  # 50% bonus for appearing multiple times
                isbn_sources[isbn].append(f"{rec['source_book']} ({rec['method']})")
            else:
                isbn_scores[isbn] = rec['score']
                isbn_sources[isbn] = [f"{rec['source_book']} ({rec['method']})"]
        
        # Sort by score and create final recommendations
        sorted_recommendations = sorted(
            isbn_scores.items(), 
            key=lambda x: x[1], 
            reverse=True
        )
        
        final_recommendations = []
        for isbn, score in sorted_recommendations[:request.limit]:
            book_info = models.all_books.get(isbn)
            if book_info:
                rec = BookRec(
                    isbn=isbn,
                    title=book_info['title']
                )
                final_recommendations.append(rec)
        
        if not final_recommendations:
            raise HTTPException(
                status_code=404, 
                detail="No recommendations could be generated for the provided books"
            )
        
        # Log recommendation summary for debugging
        logger.info(f"Generated {len(final_recommendations)} recommendations from {num_found_books} input books")
        if not_found_books:
            logger.warning(f"Books not found: {', '.join(not_found_books)}")
        
        return final_recommendations
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in item recommendations: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to generate recommendations: {str(e)}")

@router.post("/recommend/item/balanced", response_model=List[BookRec])
async def recommend_items_balanced(request: ItemRecRequest):
    """Get hybrid item-based recommendations with explicit round-robin balancing"""
    if not models.is_loaded():
        raise HTTPException(status_code=503, detail="Models not loaded. Please retrain first.")
    
    try:
        found_books = []
        not_found_books = []
        
        # Validate input books
        for title in request.book_titles:
            target_isbn = find_book_by_title(title)
            if target_isbn:
                found_books.append((title, target_isbn))
            else:
                not_found_books.append(title)
        
        if not found_books:
            raise HTTPException(
                status_code=404, 
                detail=f"None of the requested books were found: {', '.join(not_found_books)}"
            )
        
        # Get recommendations for each book
        all_book_recs = []
        for title, isbn in found_books:
            collab_recs = get_collaborative_recommendations(isbn, request.limit)
            content_recs = get_content_recommendations(isbn, request.limit)
            
            # Interleave collaborative and content recommendations
            book_recs = []
            max_len = max(len(collab_recs), len(content_recs))
            
            for i in range(max_len):
                if i < len(collab_recs) and collab_recs[i] in models.all_books:
                    book_recs.append(collab_recs[i])
                if i < len(content_recs) and content_recs[i] in models.all_books:
                    book_recs.append(content_recs[i])
            
            all_book_recs.append({
                'title': title,
                'isbn': isbn,
                'recommendations': book_recs
            })
        
        # Round-robin selection from all books
        final_recommendations = []
        seen_isbns = set()
        max_recs_per_book = max(len(book_data['recommendations']) for book_data in all_book_recs)
        
        for round_idx in range(max_recs_per_book):
            if len(final_recommendations) >= request.limit:
                break
                
            for book_data in all_book_recs:
                if len(final_recommendations) >= request.limit:
                    break
                    
                if round_idx < len(book_data['recommendations']):
                    rec_isbn = book_data['recommendations'][round_idx]
                    
                    if rec_isbn not in seen_isbns:
                        seen_isbns.add(rec_isbn)
                        book_info = models.all_books.get(rec_isbn)
                        
                        if book_info:
                            rec = BookRec(
                                isbn=rec_isbn,
                                title=book_info['title']
                            )
                            final_recommendations.append(rec)
        
        if not final_recommendations:
            raise HTTPException(
                status_code=404, 
                detail="No recommendations could be generated for the provided books"
            )
        
        logger.info(f"Balanced recommendations: {len(final_recommendations)} from {len(found_books)} books")
        return final_recommendations
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in balanced item recommendations: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to generate recommendations: {str(e)}")



@router.post("/recommend/user", response_model=List[BookRec])
async def recommend_user_items(request: UserRecRequest):
    """Get user-based recommendations"""
    if not models.is_loaded():
        raise HTTPException(status_code=503, detail="Models not loaded. Please retrain first.")
    
    try:
        # Get user's ratings
        user_ratings = await get_user_ratings(request.user_id)
        
        if not user_ratings:
            raise HTTPException(
                status_code=404, 
                detail=f"No ratings found for user: {request.user_id}"
            )
        
        recommendations = []
        
        # Check if user exists in collaborative filtering model
        if request.user_id in models.user_idx_map and models.user_model:
            user_idx = models.user_idx_map[request.user_id]
            
            try:
                # Find similar users
                distances, indices = models.user_model.kneighbors(
                    models.user_features[user_idx].reshape(1, -1),
                    n_neighbors=min(10, len(models.user_idx_map))
                )
                
                rated_items = set(user_ratings.keys())
                seen_items = set()
                
                # Collect recommendations from similar users
                for sim_user_idx in indices[0][1:]:  # Skip self
                    if len(recommendations) >= request.limit:
                        break
                        
                    sim_user_id = models.idx_user_map[sim_user_idx]
                    sim_ratings = await get_user_ratings(sim_user_id)
                    
                    for isbn, rating in sim_ratings.items():
                        if (isbn not in rated_items and 
                            isbn not in seen_items and 
                            rating >= request.min_rating_threshold and
                            len(recommendations) < request.limit):
                            
                            seen_items.add(isbn)
                            book_info = models.all_books.get(isbn)
                            
                            if book_info:
                                rec = BookRec(
                                    isbn=isbn,
                                    title=book_info['title']
                                )
                                recommendations.append(rec)
                
            except Exception as e:
                logger.error(f"Error in collaborative filtering: {e}")
        
        # Fill with content-based recommendations if needed
        if len(recommendations) < request.limit:
            # Use user's highest rated books as seeds
            top_rated = sorted(user_ratings.items(), key=lambda x: x[1], reverse=True)[:3]
            
            for isbn, rating in top_rated:
                if rating >= request.min_rating_threshold:
                    content_recs = get_content_recommendations(isbn, 10)
                    
                    for rec_isbn in content_recs:
                        if (rec_isbn not in user_ratings and 
                            len(recommendations) < request.limit):
                            
                            book_info = models.all_books.get(rec_isbn)
                            if book_info:
                                rec = BookRec(
                                    isbn=rec_isbn,
                                    title=book_info['title']
                                )
                                recommendations.append(rec)
        
        if not recommendations:
            raise HTTPException(
                status_code=404, 
                detail=f"No recommendations could be generated for user: {request.user_id}"
            )
        
        return recommendations[:request.limit]
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in user recommendations: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to generate user recommendations: {str(e)}")

@router.post(
    "/recommend",
    response_model=List[Book],
    summary="Recommend similar books by semantic search",
)
async def recommend_books(query: Query):
    """
    Accepts:
      - query.text: the free-text search string
    Returns:
      - a list of Book objects (isbn10, title, authors…)
    """
    return recommend_books_logic(query.text)



@router.get("/recommend/{user_id}", response_model=List[str])
async def recommend_for_user(user_id: str, top_n: int = 12):
    ratings_list = await load_user_ratings(user_id)
    if not ratings_list:
        raise HTTPException(status_code=404, detail=f"No ratings found for user {user_id}")
    user_dict = {r['isbn10']: r['rating'] for r in ratings_list}
    u = fold_in_user(user_dict).reshape(1, -1)
    u_proj = u * models.svd_model.singular_values_
    dists, idxs = models.item_model.kneighbors(u_proj, n_neighbors=top_n + len(user_dict))
    recommendations = []
    for idx in idxs.flatten():
        isbn = models.idx_item_map[idx]
        if isbn not in user_dict:
            recommendations.append(isbn)
        if len(recommendations) >= top_n:
            break
       
    return recommendations

@router.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "models_loaded": models.is_loaded(),
        "total_books": len(models.all_books),
        "books_with_ratings": len(models.item_idx_map),
        "last_retrain": models.last_retrain.isoformat() if models.last_retrain else None
    }

