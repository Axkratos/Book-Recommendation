# backend/build_model.py

import os
import pandas as pd
import numpy as np
from scipy.sparse import csr_matrix
from sklearn.neighbors import NearestNeighbors
import joblib
from datetime import datetime

def log(msg):
    print(f"[{datetime.now():%H:%M:%S}] {msg}")

# ─── CONFIG ─────────────────────────────────────────────────────────────────
ART_DIR = os.path.join(os.path.dirname(__file__), "artifacts")
os.makedirs(ART_DIR, exist_ok=True)

# ─── 1) Load CSVs ────────────────────────────────────────────────────────────
log("📥 Loading CSVs…")
ratings = pd.read_csv("../../dataset/Ratings.csv", usecols=["User-ID","ISBN","Book-Rating"])
books   = pd.read_csv("../../dataset/Books.csv",   usecols=["ISBN","Book-Title"])
ratings.columns = ["user_id","ISBN","rating"]
books  .columns = ["ISBN","title"]
log(f"✅ Ratings: {len(ratings):,} rows; Books: {len(books):,} rows")

# ─── 2) Merge to get titles in ratings ──────────────────────────────────────
log("🔗 Merging ratings with titles…")
df = ratings.merge(books, on="ISBN", how="inner")
log(f"✅ Merged: {len(df):,} rows")

# ─── 3) Create mappings to integer indices ─────────────────────────────────
log("🔢 Generating title & user indices…")
titles = df["title"].unique().tolist()
users  = df["user_id"].unique().tolist()
title_to_idx = {t:i for i,t in enumerate(titles)}
user_to_idx  = {u:i for i,u in enumerate(users)}
n_titles = len(titles)
n_users  = len(users)
log(f"✅ {n_titles:,} unique titles; {n_users:,} unique users")

# ─── 4) Build sparse rating matrix ──────────────────────────────────────────
log("🧩 Building sparse rating matrix…")
rows = df["title"].map(title_to_idx).to_numpy()
cols = df["user_id"].map(user_to_idx).to_numpy()
data = df["rating"].to_numpy()
sparse_mat = csr_matrix((data, (rows, cols)), shape=(n_titles, n_users))
log(f"✅ Sparse matrix shape: {sparse_mat.shape}, nnz={sparse_mat.nnz:,}")

# ─── 5) Train NearestNeighbors ──────────────────────────────────────────────
log("🤖 Training NearestNeighbors (item-CF)…")
model = NearestNeighbors(metric="minkowski", p=2, algorithm="brute")
model.fit(sparse_mat)
log("✅ Model trained")

# ─── 6) Build ISBN map ─────────────────────────────────────────────────────
isbn_map = dict(zip(books["title"], books["ISBN"]))

# ─── 7) Dump artifacts ──────────────────────────────────────────────────────
log("💾 Dumping artifacts…")
joblib.dump(model,      os.path.join(ART_DIR, "model_ib.pkl"))
joblib.dump(titles,     os.path.join(ART_DIR, "titles.pkl"))
joblib.dump(isbn_map,   os.path.join(ART_DIR, "isbn_map.pkl"))
joblib.dump(user_to_idx,os.path.join(ART_DIR, "user_to_idx.pkl"))
joblib.dump(title_to_idx,os.path.join(ART_DIR, "title_to_idx.pkl"))
log("✅ All artifacts saved to ./artifacts/")
