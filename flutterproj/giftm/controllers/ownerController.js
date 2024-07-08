import Store from '../models/storeModel.js';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import Product from '../models/productModel.js';
import User from '../models/userModel.js';

/**
 * Function to add a new store to the database, related to the authenticated user's ID.
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 */
export async function addStore(req, res) {
    const { storeName, phoneNumber, email, description, image, city } = req.body;
    const storeOwner = req.user.userId;  // Extract the store owner's ID from the verified token

    // Check if all required fields are present
    if (!storeName || !phoneNumber || !email || !description || !image || !city ) {
        return res.status(400).json({ status: 'error', message: 'Required fields are missing.' });
    }

    // Hash the password
    // const hashedPassword = await bcrypt.hash(password, 10);

    try {
        const newStore = new Store({
            storeName: storeName,
            phoneNumber: phoneNumber,
            email: email, 
            description: description,
            profileImage: image, 
            storeOwner: storeOwner,
            address: '', 
            rating: 0, 
            verified: false, 
            licenseImage: null, 
            city: city
        });

        // Save the new store to the database
        const savedStore = await newStore.save();

        res.status(201).json({
            status: 'success',
            message: 'Store successfully added.',
            store: savedStore
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to add store: ${error.message}` });
    }
}





export const getStoresByUserId = async (req, res) => {
    try {
        const userId = req.user.userId; // User ID from the verified JWT
        const stores = await Store.find({ storeOwner: userId });
        res.status(200).json({ status: 'success', data: stores });
    } catch (error) {
        res.status(500).json({ status: 'error', message: error.message });
    }
};

export async function authenticateStore(req, res) {
    const {storeId} = req.body;

    if (!storeId) {
        return res.status(400).json({ message: 'Store ID required' });
    }

    try {
        const store = await Store.findById(storeId);
        if (!store) {
            return res.status(404).json({ message: 'Store not found.' });

            }


    const token = jwt.sign({ storeId: store._id }, process.env.JWT_SECRET_KEY, { expiresIn: '500d' });

        res.json({
            message: 'Authentication successful',
            token: token,
            verified: store.verified,
            storeName: store.storeName,
            image : store.licenseImage
        });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
}

/**
 * Get all stores from the system 
 * @param {Object} req HTTP request object.
 * @param {Object} res HTTP response object.
 */

export async function getallStores(req, res) {
    try {
        const stores = await Store.find({}); // Make sure this returns all needed fields
        if (stores.length === 0) {
            return res.status(404).json({ status: 'error', message: 'No stores found.' });
        }
        res.status(200).json({
            status: 'success',
            message: 'Stores successfully fetched.',
            stores: stores.map(store => ({
                storeId: store._id,
                storeName: store.storeName, // Assumed actual field name in your schema
                description: store.description, // Assumed actual field name in your schema
                rating: parseFloat(store.rating.toString()), // Assumed actual field name in your schema
                profileImage: store.profileImage, // Assumed actual field name in your schema
                verified: store.verified,
                city: store.city// Assumed actual field name in your schema
            }))
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to get stores: ${error.message}` });
    }
}

/**
 * Get all products for a specific store
 * @param {Object} req - Express request object, containing the parameters.
 * @param {Object} res - Express response object used to return the response.
 */
export async function getAllProductsByStore(req, res) {
    const storeId = req.params.storeId; // Make sure 'storeId' matches the name in the route parameter

    if (!storeId) {
        return res.status(400).json({ status: 'error', message: 'Store ID is required.' });
    }

    try {
        const products = await Product.find({ storeId: storeId });
        if (!products.length) {
            return res.status(404).json({ status: 'error', message: 'No products found for this store.' });
        }
        res.status(200).json({ status: 'success', message: `Products fetched successfully for store ID: ${storeId}`, products });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Error fetching products for store: ${error.message}` });
    }
}


/**
 * Get all products for a specific store
 * @param {Object} req - Express request object, containing the parameters.
 * @param {Object} res - Express response object used to return the response.
 */
export async function getstoreByid(req, res) {
    const storeId = req.params.storeId; // Make sure 'storeId' matches the name in the route parameter

    if (!storeId) {
        return res.status(400).json({ status: 'error', message: 'Store ID is required.' });
    }

    try {
        const products = await Product.find({ storeId: storeId });
        if (!products.length) {
            return res.status(404).json({ status: 'error', message: 'No products found for this store.' });
        }
        res.status(200).json({ status: 'success', message: `Products fetched successfully for store ID: ${storeId}`, products });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Error fetching products for store: ${error.message}` });
    }
}



export async function getStoreInfo(req, res) {
    const storeId = req.params.storeId.trim();

    try {
        const store = await Store.findById(storeId);

        if (!store) {
            return res.status(404).json({ status: 'error', message: `Store not found with ID: ${storeId}.` });
        }

        const storeData = {
            storeName: store.storeName,
            phoneNumber: store.phoneNumber,
            email: store.email,
            address: store.address,
            profileImage: store.profileImage,
            description: store.description,
            rating: store.rating ? store.rating.toString() : null,
            verified: store.verified,
            licenseImage: store.licenseImage,
            storeOwner: store.storeOwner
        };

        res.status(200).json({
            status: 'success',
            message: `Store info fetched successfully for store ID: ${storeId}`,
            store: storeData
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to get store info: ${error.message}` });
    }
}

export async function updateStoreImage(req, res) {
    const storeId = req.store?.storeId;
    const {licenseImageUrl} = req.body;

    if (!licenseImageUrl) {
        return res.status(400).json({
            status: 'error',
            message: 'Missing store ID or image URL.'
        });
    }

    try {
        const updatedStore = await Store.findByIdAndUpdate(
            storeId,
            { licenseImage: licenseImageUrl },
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
        res.status(500).json({
            status: 'error',
            message: `Error updating store: ${error.message}`
        });
    }
};