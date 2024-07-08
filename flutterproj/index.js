import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv'; 

dotenv.config(); 


import userRoutes from './routes/userRoutes.js';
import storeRoutes from './routes/storeRoutes.js';

const app = express();
app.use(cors());
app.use(express.json());

app.use('/user', userRoutes);
app.use('/store', storeRoutes);

app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send('Something went wrong!');
  });
  
  const PORT = process.env.PORT || 3012; 
 
  app.listen(PORT, () => {
  
    console.log(`The Server is running on port ${PORT}`);
  });
  