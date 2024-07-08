
import express from 'express';
import {
    addProduct,
    deleteProduct,
    updateProduct,
} from '../controllers/storeProdControllers.js';
import{
    addDiscountToProduct,
    addDiscountToAllProducts,
} from '../controllers/storeDiscController.js';

import authMiddleware  from '../middleware/auth.js'; 

const userRouter =express.Router();

userRouter.post('/addProduct', authMiddleware, addProduct); 
userRouter.delete('/deleteprod/:ProductId', authMiddleware, deleteProduct);
userRouter.put('/updateProduct/:ProductId', authMiddleware, updateProduct); 
userRouter.put('/addDiscount/:ProductId', authMiddleware, addDiscountToProduct); 
userRouter.put('/addDiscountAll', authMiddleware, addDiscountToAllProducts); 

// Export store Router
export default userRouter;