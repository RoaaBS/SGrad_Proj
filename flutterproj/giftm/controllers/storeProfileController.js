import _express from 'express';
import _mongoose from 'mongoose';
import _crypto from 'crypto';
import User from '../models/userModel.js';
import Store from '../models/storeModel.js';



export async function updateStoreName(req, res) {
    const storeId = req.store?.storeId;
    const { storeName } = req.body;

    try {
        const store = await Store.findByIdAndUpdate(storeId, { storeName }, { new: true });

        if (!store) {
            return res.status(404).json({ status: 'error', message: 'Store not found.' });
        }

        res.status(200).json({
            status: 'success',
            message: 'Store name updated successfully',
            store: { storeName: store.storeName }
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to update store name: ${error.message}` });
    }
}

export async function updateStorePhoneNumber(req, res) {
    const storeId = req.store?.storeId;
    const { phoneNumber } = req.body;

    try {
        const store = await Store.findByIdAndUpdate(storeId, { phoneNumber }, { new: true });

        if (!store) {
            return res.status(404).json({ status: 'error', message: 'Store not found.' });
        }

        res.status(200).json({
            status: 'success',
            message: 'Phone number updated successfully',
            store: { phoneNumber: store.phoneNumber }
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to update phone number: ${error.message}` });
    }
}

export async function getStoreProfile(req, res) {
    try {
        const storeId = req.store?.storeId;
        const store = await Store.findById(storeId);

        if (!store) {
            return res.status(404).json({ status: 'error', message: 'store not found.' });
        }

        res.status(200).console.log(res).json({
            status: 'success',
            message: 'Profile retrieved successfully.',
            store
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Error retrieving user profile: ${error.message}` });
    }
}

export async function updateStoreProfileImage(req, res) {
    const storeId = req.store?.storeId;
    const {profileImage } = req.body;

    if (!profileImage) {
        return res.status(400).json({
            status: 'error',
            message: 'Missing store ID or image URL.'
        });
    }

    try {
        const updatedStore = await Store.findByIdAndUpdate(
            storeId,
            { profileImage: profileImage },
            { new: true }
        );

        if (!updatedStore) {
            return res.status(404).json({
                status: 'error',
                message: 'Store not found.'
            });
        }

        res.status(200).json({
            status: 'success',
            message: 'License image updated successfully.',
            data: updatedStore
        });
    } catch (error) {
        console.error("Error updating store:", error);  // Print the error to the terminal
        res.status(500).json({
            status: 'error',
            message: `Error updating store: ${error.message}`
        });
    }
};


export async function updateStoreCity(req, res) {
    const storeId = req.store?.storeId;
    const { city } = req.body;

    try {
        const store = await Store.findByIdAndUpdate(storeId, { city }, { new: true });

        if (!store) {
            return res.status(404).json({ status: 'error', message: 'Store not found.' });
        }

        res.status(200).json({
            status: 'success',
            message: 'city updated successfully',
            store: { city : store.city }
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to update phone number: ${error.message}` });
    }
}