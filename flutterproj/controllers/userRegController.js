
import User from '../models/userModel.js';
import Code from '../models/codeModel.js';
import { sendResetPasswordEmail, generateUniqueCode } from '../utility/emailUtils.js';
import { generateToken } from '../utility/tokenUtils.js';


// User Register 
export const userRegister = async (req, res) => {
    try 
    {
      const {username, email, password, confirmPassword, phonenumber, useraddress, type, profilepicture, bio} = req.body;
     
      if (!username ||!email ||!type || !phonenumber ||!password || !confirmPassword) {
        return res.status(400).json(' ادخل جميع الخانات اللازمة')
      }
  
       const userExist = await User.findOne({ where: {Email : email} });
       if (userExist) {
           return res.status(400).json('الايميل مستخدم في حساب مسبق')
       }
  
      if (password !== confirmPassword) {
        return res.status(400).json('كلمة السر غير متطابقة' );
      }
      const user = await User.create({   
        Username: username,  
        Email: email,   
        Password: password,
        Phonenumber:phonenumber,
        Address: useraddress, 
        UserType:type,
        UserProfileInfo: bio !== "" ? bio : 'ضع وصف لمحلك الشخصي',
        UserPicture: profilepicture !== "" ? profilepicture : 'images/profilePic96.png' ,
        Rating:0.0,
    });
    const token = generateToken(user.User_id);

      res.status(200).json({
        userID: user.User_id,
        userType: user.UserType,
        token: token
      });
  
  } catch (error) {
    console.error('User Registration Error:', error);

    if (error.name === 'SequelizeValidationError') {
      return res.status(400).json({ error: 'Validation error. Please provide valid data' });
    }

    res.status(500).json({ error: 'User Registration Failed' });
  }
};

// User Login 
export const userLogin = async (req, res) => {
    try 
  {
    const { email, password } = req.body;
    
    if (!email || !password) {
      return res.status(400).json('ادخل جميع البيانات اللازمة');
    }

    const user = await User.findOne({ where: {Email : email} });

    if (!user) {
      return res.status(400).json('ايميل خاطئ');
    }


    if (user.Password !== password) {
      return res.status(400).json('كلمة سر خاطئة');
    }
    const token = generateToken(user.User_id);
    await user.save();
    
    res.status(200).json({
        userID: user.User_id,
        userType: user.UserType,
        token: token
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'User login failed' });
  }
  };



// Forgot Password Handler
// Forgot Password Handler
export const forgotPassword = async (req, res) => {
  const { email } = req.body;
  try {
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    const resetCode = generateUniqueCode();
    
    // Store the reset code directly without hashing
    await Code.create({
      userId: user.User_id, // Ensure this is the correct identifier (e.g., `id` if your user model uses `id` as the primary key)
      codeHash: resetCode, // Store the code in plain text (Consider renaming this column if it's no longer a hash)
      expiresAt: new Date(Date.now() +10*60*1000), // Expires in 1 hour
      createdAt: new Date(),

    });
    
    await sendResetPasswordEmail(email, resetCode);
    res.status(200).json({ message: 'Password reset email sent' });
  } catch (error) {
    res.status(500).json({ message: 'Error sending password reset email', error: error.message });
  }
};


// Verify Reset Code Handler
export const verifyCode = async (req, res) => {
  try {
    const { userId } = req.params; 
    const { providedCode } = req.body;
  
    const code = await Code.findOne({
      where: {
        userId: userId,
      },
      order: [['createdAt', 'DESC']], 
    });
  
    if (!code) {
      return res.status(401).json({ error: 'Code not found' });
    }
    
    // Direct comparison since the code is not hashed
    if (providedCode) {
      return res.status(400).json('Invalid Code');
    }

    const now = new Date();
    if (code.expiresAt < now) {
      return res.status(400).json('Code has expired');
    }

    res.status(200).json('Verification Successful');
  
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Invalid Verification Code' });
  }
};


// Reset Password Handler
export const resetPassword = async (req, res) => {
  const { userId } = req.params;
  const { newPassword, confirmPassword } = req.body;

  // Log the received userId for debugging
  console.log(`Resetting password for UserID: ${userId}`);

  // Check if new passwords match
  if (newPassword !== confirmPassword) {
    console.log('Passwords do not match.');
    return res.status(400).json({ message: 'New Password and Confirm Password do not match' });
  }

  try {
    // Find the user by their primary key
    const user = await User.findByPk(userId);
    if (!user) {
      console.log(`User not found for ID: ${userId}`);
      return res.status(404).json({ message: 'User not found' });
    }

    // Set the new password directly without hashing (Note: It's highly recommended to hash passwords)
    user.set('Password', newPassword);
    user.changed('Password', true); // Mark the Password field as changed
    await user.save();

    console.log(`Password reset successfully for UserID: ${userId}`);
    return res.status(200).json({ message: 'Password Reset Successful' });

  } catch (error) {
    // Log the error for debugging purposes
    console.error(`Error resetting password for UserID: ${userId}`, error);
    return res.status(500).json({ message: 'Password Reset Failed', error: error.toString() });
  }
};
