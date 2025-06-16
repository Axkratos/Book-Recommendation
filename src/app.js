import express from 'express';
import cors from 'cors'
import cookieParser from 'cookie-parser';
import cron from 'node-cron';
import updateTrendingBooks from './utils/trendingUpdater.js';
import rateLimit from 'express-rate-limit';  // ← add this
import helmet from 'helmet';
import mongoSanitize from 'express-mongo-sanitize';



const app = express();
// 1) Users endpoints: fairly generous
const usersLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 min
  max: 200,                 // 200 calls per IP per window
  standardHeaders: true,
  legacyHeaders: false,
  message: { status: 429, error: 'Too many user requests, slow down.' }
});

// 2) Auth endpoints: very strict
const authLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 10,                   // only 5 login/signup attempts
  standardHeaders: true,
  legacyHeaders: false,
  message: { status: 429, error: 'Too many auth attempts, try again later.' }
});

// 3) Books endpoints: moderate
const booksLimiter = rateLimit({
  windowMs: 5 * 60 * 1000,  // 5 min
  max: 120,                 // 120 calls per IP per window
  standardHeaders: true,
  legacyHeaders: false,
  message: { status: 429, error: 'Too many book requests, please wait.' }
});

app.use(helmet());              // secure headers
app.use(mongoSanitize());       // sanitize NoSQL queries

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

cron.schedule('0 2 * * *', () => {
    console.log('🕑 [Cron] Running daily trending update at 2:00 AM…');
    updateTrendingBooks();
  });

//  updateTrendingBooks();


// importing Routes
import userRoutes from './routes/userRoute.js'
import authRoutes from './routes/authRoute.js';
import bookRoutes from './routes/bookRoute.js';




// Setting the routes
app.use('/api/v1/users/',usersLimiter,userRoutes);
app.use('/api/v1/auth/',authLimiter,authRoutes);
app.use('/api/v1/books/',booksLimiter,bookRoutes);



export { app }


