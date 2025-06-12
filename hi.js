// update-thumbnails-openlibrary.js

import mongoose from "mongoose";
import Book from "./src/models/bookModel.js";  // adjust path if needed

const MONGODB_URI = "mongodb+srv://anup:1234@cluster0.ym6mtak.mongodb.net/bookrec";

async function main() {
  await mongoose.connect(MONGODB_URI);
  console.log("🗄️  Connected to MongoDB");

  // This will match any thumbnail URL containing "books.google.com/books/content"
  // and replace thumbnail with:
  //    https://covers.openlibrary.org/b/isbn/<isbn10>-M.jpg
  const res = await Book.updateMany(
    { thumbnail: /books\.google\.com\/books\/content/ },
    [
      {
        $set: {
          thumbnail: {
            $concat: [
              "https://covers.openlibrary.org/b/isbn/",
              "$isbn10",
              "-M.jpg"
            ]
          }
        }
      }
    ],
    { ordered: false }
  );

  console.log("🔄 Matched:", res.matchedCount, "Modified:", res.modifiedCount);
  await mongoose.disconnect();
  console.log("🎉 Done.");
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
