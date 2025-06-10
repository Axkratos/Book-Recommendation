import express from 'express';
import cors from 'cors'
import cookieParser from 'cookie-parser';
import cron from 'node-cron';
import updateTrendingBooks from './utils/trendingUpdater.js';

const app = express();

// CORS configuration
app.use(cors(
  {
    origin: process.env.CORS_ORIGIN,
    credentials: true
  }
))

// Json Parser configuration
app.use(express.json({
    limit: "16kb"
}))

// URL encoding configuration
app.use(express.urlencoded({
    extended: true,
    limit: "16kb"
}))


// For Static files configuration
app.use(express.static("public"))

// Setting up cookie parser
app.use(cookieParser());

cron.schedule('0 12 * * *', () => {
    console.log('🕑 [Cron] Running daily trending update at 2:00 AM…');
    updateTrendingBooks();
  });



// importing Routes
import userRoutes from './routes/userRoute.js'
import authRoutes from './routes/authRoute.js';
import bookRoutes from './routes/bookRoute.js';

// Setting the routes
app.use('/api/v1/users/',userRoutes);
app.use('/api/v1/auth/',authRoutes);
app.use('/api/v1/books/',bookRoutes);


export { app }


