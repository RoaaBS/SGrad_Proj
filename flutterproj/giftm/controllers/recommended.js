import mongoose from 'mongoose';
import Order from '../models/orderModel.js';
import Favorite from '../models/favoriteModel.js'
import Product from '../models/productModel.js';
import Store from '../models/storeModel.js';

// export async function getUserPreferredCategory(req, res) {
//     try {
//         const userId = req.user?.userId;

//         // Verify if userId is received
//         if (!userId) {
//             return res.status(400).json({ success: false, message: 'User ID is missing' });
//         }

//         const favoriteCategories = await Favorite.aggregate([
//             { $match: { userId: new mongoose.Types.ObjectId(userId) }},
//             { $lookup: {
//                 from: 'products',
//                 localField: 'productId',
//                 foreignField: '_id',
//                 as: 'productDetails'
//             }},
//             { $unwind: '$productDetails' },
//             { $group: {
//                 _id: '$productDetails.category',
//                 count: { $sum: 1 }
//             }},
//             { $sort: { count: -1 } }
//         ]);

//         const orderCategories = await Order.aggregate([
//             { $match: { user: new mongoose.Types.ObjectId(userId) }},
//             { $unwind: '$items' },
//             { $lookup: {
//                 from: 'products',
//                 localField: 'items.product',
//                 foreignField: '_id',
//                 as: 'productDetails'
//             }},
//             { $unwind: '$productDetails' },
//             { $group: {
//                 _id: '$productDetails.category',
//                 count: { $sum: '$items.quantity' }
//             }},
//             { $sort: { count: -1 } }
//         ]);

//         // Combine the results and find the most preferred category
//         const combinedCategories = [...favoriteCategories, ...orderCategories];
//         const categoryCounts = combinedCategories.reduce((acc, category) => {
//             acc[category._id] = (acc[category._id] || 0) + category.count;
//             return acc;
//         }, {});

//         if (Object.keys(categoryCounts).length === 0) {
//             return res.status(404).json({ success: false, message: 'No categories found for the user' });
//         }

//         const mostPreferredCategory = Object.keys(categoryCounts).reduce((a, b) => categoryCounts[a] > categoryCounts[b] ? a : b);
//         res.status(200).json({ success: true, data: mostPreferredCategory });
//     } catch (error) {
//         console.error("Error:", error.message);
//         res.status(500).json({ success: false, message: error.message });
//     }
// }
export async function getUserPreferredCategory(userId) {
    try {
        const favoriteCategories = await Favorite.aggregate([
            { $match: { userId: new mongoose.Types.ObjectId(userId) }},
            { $lookup: {
                from: 'products',
                localField: 'productId',
                foreignField: '_id',
                as: 'productDetails'
            }},
            { $unwind: '$productDetails' },
            { $group: {
                _id: '$productDetails.category',
                count: { $sum: 1 }
            }},
            { $sort: { count: -1 } }
        ]);

        const orderCategories = await Order.aggregate([
            { $match: { user: new mongoose.Types.ObjectId(userId) }},
            { $unwind: '$items' },
            { $lookup: {
                from: 'products',
                localField: 'items.product',
                foreignField: '_id',
                as: 'productDetails'
            }},
            { $unwind: '$productDetails' },
            { $group: {
                _id: '$productDetails.category',
                count: { $sum: '$items.quantity' }
            }},
            { $sort: { count: -1 } }
        ]);

        // Combine the results and find the most preferred category
        const combinedCategories = [...favoriteCategories, ...orderCategories];
        const categoryCounts = combinedCategories.reduce((acc, category) => {
            acc[category._id] = (acc[category._id] || 0) + category.count;
            return acc;
        }, {});

        if (Object.keys(categoryCounts).length === 0) {
            throw new Error('No categories found for the user');
        }

        return Object.keys(categoryCounts).reduce((a, b) => categoryCounts[a] > categoryCounts[b] ? a : b);
    } catch (error) {
        throw error;
    }
}


export async function getStoresByCategory(req, res) {
    try {
        const category = req.params.category;
        
        if (!category) {
            return res.status(400).json({ success: false, message: 'Category is missing' });
        }

        // Find all unique storeIds for products in the given category
        const products = await Product.find({ category: category }).distinct('storeId');

        if (!products || products.length === 0) {
            return res.status(404).json({ success: false, message: 'No products found in this category' });
        }

        // Find all stores corresponding to the storeIds and convert rating
        const stores = await Store.aggregate([
            { $match: { _id: { $in: products.map(id => new mongoose.Types.ObjectId(id)) } }},
            { $addFields: {
                rating: { $toString: "$rating" }
            }}
        ]);

        if (!stores || stores.length === 0) {
            return res.status(404).json({ success: false, message: 'No stores found for the products in this category' });
        }

        res.status(200).json({ success: true, data: stores });
    } catch (error) {
        console.error("Error:", error.message);
        res.status(500).json({ success: false, message: error.message });
    }
}

export async function recommendStoresForUser(req, res) {
    try {
        const userId = req.user?.userId;

        if (!userId) {
            return res.status(400).json({ success: false, message: 'User ID is missing' });
        }

        // Retrieve the preferred category from the user data
        const preferredCategory = await getUserPreferredCategory(userId);
        
        // Set the category to be used in the next function call
        req.params.category = preferredCategory;

        // Call getStoresByCategory with the dynamically set category
        return await getStoresByCategory(req, res);
    } catch (error) {
        console.error("Error:", error.message);
        res.status(500).json({ success: false, message: error.message });
    }
}
