import _express from 'express';
import _mongoose from 'mongoose';
import _crypto from 'crypto';
const express = _express;
const mongoose = _mongoose;
import nodemailer from 'nodemailer';
import User from '../models/userModel.js';
import bcrypt from 'bcryptjs';

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'serovibe2024@gmail.com',
      pass: 'mehc einr egbc rhzl',
    }
});

const sendEmail = async (email, subject, text) => {
    const mailOptions = {
        from:  'serovibe2024@gmail.com',
        to: email,
        subject: subject,
        text: text,
    };

    try {
        const info = await transporter.sendMail(mailOptions);
        console.log('Email sent: ' + info.response);
    } catch (error) {
        console.error('Failed to send email', error);
    }
};

export const requestPasswordReset = async (req, res) => {
    const { email } = req.body;
    try {
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ msg: 'المستخدم غير موجود' });
        }

        const verificationCode = Math.floor(100000 + Math.random() * 900000);
        user.resetPasswordToken = verificationCode;
        user.resetPasswordExpires = Date.now() + 3600000; // 1 hour from now
        await user.save();

        await sendEmail(
            user.email,
            "رمز التحقق الخاص بك",
            `استخدم هذا الرمز لإعادة تعيين كلمة المرور: ${verificationCode}`
        );

        res.json({ msg: 'تم إرسال رمز التحقق لإعادة تعيين كلمة المرور إلى بريدك الإلكتروني.' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('خطأ في الخادم');
    }
};

export const resetPassword = async (req, res) => {
    const { email, verificationCode, newPassword } = req.body;

    try {
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ msg: 'المستخدم غير موجود' });
        }

        if (user.resetPasswordToken !== verificationCode || user.resetPasswordExpires < Date.now()) {
            return res.status(400).json({ msg: 'رمز التحقق غير صالح أو انتهت صلاحيته' });
        }

        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(newPassword, salt);
        user.resetPasswordToken = undefined;
        user.resetPasswordExpires = undefined;
        await user.save();

        res.json({ msg: 'تم تحديث كلمة المرور بنجاح.' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('خطأ في الخادم');
    }
};

// /**
//  * Retrieves the profile information of the logged-in user.
//  * @param {Object} req - The request object. Expects user ID in req.user.userId
//  * @param {Object} res - The response object.
//  */
export const  getUserProfile=async(req, res) =>{
    const userId = req.user.userId; // Assuming the userID is attached to req.user by verifyToken middleware
  
    try {
        const user = await User.findById(userId).select('-password -_id -verificationCode -resetPasswordToken -resetPasswordExpires');
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Prepare data to send, conditionally excluding fields based on userType
        const responseData = {
            username: user.username,
            userType: user.userType,
            email: user.email,
            phoneNumber: user.phoneNumber || null,
            address: user.address || null,
            userPicture: user.userPicture || null
        };

        // Include additional fields for "صاحب متجر"
        if (user.userType === 'صاحب متجر') {
            responseData.userProfileInfo = user.userProfileInfo || null;
            responseData.rating = user.rating || null;
            responseData.verified = user.verified;
            responseData.licenseImage = user.licenseImage || null;
        }

        res.json({
            status: 'success',
            data: responseData
        });
    } catch (error) {
        res.status(500).json({ message: `Error retrieving user data: ${error.message}` });
    }
}




/**
 * Adds a new Address to the store using the store owner's ID extracted from the JWT token.
 * @param {Object} req HTTP request object.
 * @param {Object} res HTTP response object.
 */



export async function addAddress(req, res) {
    const userId = req.params.id;
    const { address } = req.body; // Make sure to extract address from the request body

    if (!address) {
        return res.status(400).json({ status: 'error', message: 'Address field must be filled.' });
    }

    try {
        // Find the user by ID and update
        const updatedUser = await User.findByIdAndUpdate(userId, { address }, { new: true });

        if (!updatedUser) {
            return res.status(404).json({ status: 'error', message: 'User not found.' });
        }

        res.status(200).json({
            status: 'success',
            message: 'Address added successfully',
            user: updatedUser
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to add address: ${error.message}` });
    }
}
