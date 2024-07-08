import _express from 'express';
import _mongoose from 'mongoose';
import _crypto from 'crypto';
import User from '../models/userModel.js';


export async function getStoreProfile(req, res) {
    try {
        const userId = req.user.userId; 
        const user = await User.findById(userId).select('-password -verificationCode -resetPasswordToken -resetPasswordExpires');

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

export async function updateUsername(req, res) {
    const userId = req.user.userId; 
    const { username } = req.body;

    try {
        // Find user by ID and update the username
        const user = await User.findByIdAndUpdate(
            userId,
            { username },
            { new: true }
        ).select('-password');

        if (!user) {
            return res.status(404).json({ status: 'error', message: 'User not found.' });
        }

        res.status(200).json({
            status: 'success',
            message: 'Username updated successfully.',
            user
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Error updating username: ${error.message}` });
    }
}

export async function updatePhoneNumber(req, res) {
    const userId = req.user.userId; 
    const { phoneNumber } = req.body;

    try {
        // Find user by ID and update the phone number
        const user = await User.findByIdAndUpdate(
            userId,
            { phoneNumber },
            { new: true }
        ).select('-password');

        if (!user) {
            return res.status(404).json({ status: 'error', message: 'User not found.' });
        }

        res.status(200).json({
            status: 'success',
            message: 'Phone number updated successfully.',
            user
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Error updating phone number: ${error.message}` });
    }
}


export async function updateUserImage(req, res) {
    const userId = req.user.userId;
    const { userPicture } = req.body; // The path to the user's profile picture

    try {
        const user = await User.findByIdAndUpdate(
            userId,
            { userPicture },
            { new: true }
        ).select('-password');

        if (!user) {
            return res.status(404).json({ status: 'error', message: 'User not found.' });
        }

        res.status(200).json({
            status: 'success',
            message: 'Profile picture updated successfully.',
            user,
        });
    } catch (error) {
        res.status(500).json({
            status: 'error',
            message: `Error updating profile picture: ${error.message}`,
        });
    }
}


export async function getUserType(req, res) {
    try {
        const userId = req.user.userId; // Assumes you have a middleware to extract user ID from JWT
        const user = await User.findById(userId).select('userType');

        if (!user) {
            return res.status(404).json({ status: 'error', message: 'User not found.' });
        }

        res.status(200).json({
            status: 'success',
            userType: user.userType
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Error retrieving user type: ${error.message}` });
    }
}

// Assuming you have express and necessary middlewares set up

export async function getUserAddress(req, res) {
    const userId = req.user?.userId; // Ensure you have authentication middleware that sets `req.user`

    if (!userId) {
        return res.status(403).send('User authentication failed.');
    }

    try {
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).send('User not found.');
        }
        res.json({ address: user.address });
    } catch (error) {
        console.error('Fetching address error:', error);
        res.status(500).send('Server error while fetching address.');
    }
};
