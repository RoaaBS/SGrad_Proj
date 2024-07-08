import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import User from '../models/userModel.js';

/**
 * Registers a new user and handles the HTTP response.
 * @param {Object} req HTTP request object.
 * @param {Object} res HTTP response object.
 */
export async function registerUser(req, res) {
    const { username, userType, email, password } = req.body;

    // Check if all fields are filled
    if (!username || !userType || !email || !password) {
        return res.status(400).json({ status: 'error', message: 'All fields are required.' });
    }

    try {
        // Check if the email is already in use
        const existingUser = await User.findOne({ email: email });
        if (existingUser) {
            return res.status(400).json({ status: 'error', message: 'Email is already in use.' });
        }

        // Hash the password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create a new user
        const newUser = new User({
            username,
            userType,
            email,
            password: hashedPassword
        });

        await newUser.save(); // Save the user to the database

        // Generate and sign JWT token with an expiration of 100 days
        const token = jwt.sign(
            { userId: newUser._id },
            process.env.JWT_SECRET_KEY,
            { expiresIn: '500d' } // 2400 hours equals approximately 100 days
        );

        // Respond with user data and token
        return res.status(201).json({
            status: 'success',
            message: 'User successfully registered.',
            user: {
                username,
                userType,
                email
            },
            token: token // Include the token in the response
        });
    } catch (error) {
        return res.status(500).json({ status: 'error', message: `An error occurred during user registration: ${error.message}` });
    }
}

// /**
//  * يقوم بتسجيل دخول المستخدم ويتعامل مع استجابة HTTP.
//  * @param {Object} req كائن طلب HTTP.
//  * @param {Object} res كائن استجابة HTTP.
//  */
export async function LoginUser(req, res) {
    const {email, password} = req.body;

    // Check if email and password are provided
    if (!email || !password) {
        return res.status(400).json({ status: 'error', message: 'الايميل و الباسورد حقول مطلوبة.' });
    }

    try {
        // Check if user exists
        const user = await User.findOne({ email: email });
        if (!user) {
            return res.status(404).json({ status: 'error', message: 'المستخدم غير موجود.' });
        }

        // Compare the password with the hashed password
        const passwordMatch = await bcrypt.compare(password, user.password);
        if (!passwordMatch) {
            return res.status(401).json({ status: 'error', message: 'الباسورد غير صحيح.' });
        }

        // Generate JWT token
        const token = jwt.sign(
            { userId: user._id, email: user.email },
            process.env.JWT_SECRET_KEY,
            { expiresIn: '500d' }  // expires in one day, adjust as needed
        );

        // Respond with user data and token
        return res.status(200).json({
            status: 'success',
            message: 'تم تسجيل دخول المستخدم بنجاح.',
            token: token,
            user: {
                username: user.username,
                userType: user.userType,
                email: user.email,
                phoneNumber: user.phoneNumber
            }
        });
    } catch (error) {
        return res.status(500).json({ status: 'error', message: `حدث خطأ أثناء تسجيل دخول المستخدم: ${error.message}` });
    }
}



export async function getAllUsers(req, res) {
    try {
        const users = await User.find({}); // استعلام للحصول على جميع المستخدمين

        res.status(200).json({
            status: 'success',
            results: users.length,
            data: {
                users
            }
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: 'Failed to retrieve users: ' + error.message });
    }
}
