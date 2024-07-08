import express from 'express';
import userRouter from './routes/userRouter.js';
import storeRouter from './routes/storeRouter.js'; // Update the import path here
import connectDb from './db/db.js';
import 'dotenv/config'
import cors from "cors";

// Create an instance of Express application
const app = express();
app.use(cors());
app.use(express.json());
connectDb();


// Use the userRouter for handling user registration route
app.use('/users', userRouter);
app.use('/stores', storeRouter);

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
