import express from 'express';
import {
  userRegister,
  userLogin,
  forgotPassword,
  verifyCode,
  resetPassword,
} from '../controllers/userRegController.js';

import { 
  getProfile,
  getProfilefromID,
  editProfile,
  editProfileImage,
 } from '../controllers/userProfileController.js';

 import authMiddleware  from '../middleware/auth.js'; 


const userRouter =express.Router();

// User Registration
userRouter.post('/register', userRegister); 

// User Login
userRouter.post('/login', userLogin);
// User Forgot Password
userRouter.post('/forgotPassword', forgotPassword);

// User Verify Code
userRouter.post('/verifyCode/:userId', verifyCode); 

// User Reset Password
userRouter.post('/resetPassword/:userId', resetPassword); 
//------------------------------------------------------------------------------//

// User get Profile
userRouter.get('/profile', authMiddleware, getProfile); 

// User get Profile from ID
userRouter.get('/profilefromID/:userId', authMiddleware, getProfilefromID);

// User edit Profile
userRouter.put('/editProfile', authMiddleware, editProfile);

// User edit Profile Image
userRouter.put('/editProfileImage', authMiddleware,editProfileImage); 

// Export User Router
export default userRouter;
