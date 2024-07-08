import _express from 'express';
import _mongoose from 'mongoose';
import _crypto from 'crypto';
import User from '../models/userModel.js';


export async function getCustomerProfile(req, res) {
    try {
        const userId = req.user.userId; 
        const user = await User.findById(userId).select('-password -verificationCode -resetPasswordToken -resetPasswordExpires -licenseImage -userProfileInfo -rating -verified');

        if (!user) {
            return res.status(404).json({ status: 'error', message: 'User not found.' });
        }

        res.status(200).json({
            status: 'success',
            message: 'Profile retrieved successfully.',
            user
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Error retrieving user profile: ${error.message}` });
    }
}
