import pandas as pd
from app.models.database import users_collection, books_collection, ratings_collection

def import_csv_to_mongo():
    users_df = pd.read_csv("dataset/Users.csv")
    books_df = pd.read_csv("dataset/Books.csv", dtype=str)
    ratings_df = pd.read_csv("dataset/Ratings.csv")

    users_df.rename(columns={'User-ID': 'user_id', 'Location': 'location', 'Age': 'age'}, inplace=True)
    books_df.rename(columns={'Book-Title': 'book_title', 'Book-Author': 'book_author',
                             'Year-Of-Publication': 'year_of_publication', 'Publisher': 'publisher'}, inplace=True)

    if users_collection.count_documents({}) == 0:
        users_collection.insert_many(users_df.to_dict('records'))
    if books_collection.count_documents({}) == 0:
        books_collection.insert_many(books_df.to_dict('records'))
    if ratings_collection.count_documents({}) == 0:
        ratings_collection.insert_many(ratings_df.to_dict('records'))

if __name__ == "__main__":
    import_csv_to_mongo()
