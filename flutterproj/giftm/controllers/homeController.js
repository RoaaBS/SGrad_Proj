import _express from 'express';
import _mongoose from 'mongoose';
import _crypto from 'crypto';
import User from '../models/userModel.js';
import Product from '../models/productModel.js';
import Store from '../models/storeModel.js';
import Order from '../models/orderModel.js';
import bodyParser from 'body-parser'; 
/**
 * @param {Object} req HTTP request object.
 * @param {Object} res HTTP response object.
 */

export async function getProducts(req, res) {
    try {
        const products = await Product.find().limit(30); // Limit to 30 products

        if (!products.length) {
            return res.status(404).json({ status: 'error', message: 'No products found.' });
        }

        res.status(200).json({
            status: 'success',
            message: `Found ${products.length} products.`,
            products
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to get products: ${error.message}` });
    }
}

export async function getAllProducts(req, res) {
    try {
        // const userId = req.user?.userId;
        const products = await Product.find();

        // if (!userId) {
        //     return res.status(403).json({ status: 'error', message: 'Access denied. No user associated with this token.' });
        // }

        if (!products.length) {
            return res.status(404).json({ status: 'error', message: 'No products found.' });
        }

        res.status(200).json({
            status: 'success',
            message: `Found ${products.length} products.`,
            products
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to get products: ${error.message}` });
    }
}




export async function getStoreRating(req, res) {
    try {
        // Fetching all stores and sorting by rating in descending order
        const stores = await Store.find({}).sort({rating: -1}).lean();

        if (!stores.length) {
            return res.status(404).json({ status: 'error', message: 'No stores found.' });
        }

        const processedStores = stores.map(store => ({
            ...store,
            rating: parseFloat(store.rating.toString())
        }));

        res.status(200).json({
            status: 'success',
            message: `Found ${processedStores.length} stores.`,
            stores: processedStores
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to retrieve stores: ${error.message}` });
    }
}


export async function getStoreNearMe(req, res) {
    try {
        const {city} = req.query;
        const stores = await Store.find({city: city}).sort({rating: -1}).lean();
        const processedStores = stores.map(store => ({
            ...store,
            rating: parseFloat(store.rating.toString())
        }));

        res.status(200).json({
            status: 'success',
            message: `Found ${stores} stores.`,
            stores: processedStores
        });
    } catch (error) {
        // do nothing.
    }
}

// export async function getBestSellingStores(req,res) {
//     try {
//         const bestSellingStores = await Order.aggregate([
//             // Filter out cancelled orders
//             { $match: { status: { $ne: 'cancelled' } } },
//             // Group by store ID
//             { 
//                 $group: {
//                     _id: '$store',
//                     totalSales: { $sum: '$total' }, // Sum up all total values for each store
//                     orderCount: { $sum: 1 } // Count the number of orders for each store
//                 }
//             },
//             // Sort by total sales in descending order
//             { $sort: { totalSales: -1 } },
//             // Lookup to fetch store details from the Store collection
//             {
//                 $lookup: {
//                     from: Store.collection.name,
//                     localField: '_id',
//                     foreignField: '_id',
//                     as: 'storeDetails'
//                 }
//             },
//             // Unwind the array to make data handling easier
//             { $unwind: '$storeDetails' },
//             // Project the desired fields
//             {
//                 $project: {
//                     _id: '$storeDetails._id',
//                     storeName: '$storeDetails.storeName',
//                     address: '$storeDetails.address',
//                     email: '$storeDetails.email',
//                     phoneNumber: '$storeDetails.phoneNumber',
//                     city: '$storeDetails.city',
//                     rating: { $ifNull: ['$storeDetails.rating', 0.0] },
//                     profileImage: '$storeDetails.profileImage',
//                     description: '$storeDetails.description',
//                     totalSales: 1,
//                     orderCount: 1 // Include the count of orders in the output
//                 }
//             }
//         ]);

//         // Map over each store to convert Decimal128 types if necessary
//         const processedStores = bestSellingStores.map(store => ({
//             ...store,
//             rating: parseFloat(store.rating.toString()), // Ensure rating is a float
//             totalSales: parseFloat(store.totalSales.toString()), // Ensure totalSales is a float
//             orderCount: store.orderCount // Ensure order count is correctly mapped
//         }));

//         return processedStores;
//     } catch (error) {
//         console.error('Failed to retrieve best-selling stores with order count:', error);
//         return [];
//     }
// }


export async function testMatch(req,res) {
    try {
        const results = await Order.find({ status: { $ne: 'cancelled' } });
        
        res.status(200).json({
            status: 'success'
        });
        console.log(results.length);
        return results.length;
          // Just to see if any documents are returned
    } catch (error) {
        console.error("Error testing match:", error);
        return 0;
    }
}


export async function getTopStoreIDs(req, res) {
    try {
        const storeCounts = await Order.aggregate([
            { $match: { status: { $ne: 'cancelled' } } },
            { $group: { _id: '$store', orderCount: { $sum: 1 } } },
            { $sort: { orderCount: -1 } },
            { $limit: 5 }
        ]);

        console.log("Store Counts:", storeCounts);
        return storeCounts.map(item => item._id);
    } catch (error) {
        console.error("Error retrieving top store IDs:", error);
        res.status(500).json({ error: 'Internal server error' });
    }
}




export async function getStoreDetails(storeIds) {
    try {
        const stores = await Store.find({
            '_id': { $in: storeIds }
        }).lean();

        // Process each store to format the rating as a float
        const processedStores = stores.map(store => ({
            ...store,
            rating: store.rating ? parseFloat(store.rating.toString()) : 0.0 // Ensuring rating is a float and handling cases where rating might be undefined
        }));

        return processedStores;
    } catch (error) {
        console.error("Error retrieving store details:", error);
        return [];
    }
}

// Function to integrate both steps
export async function getBestSellingStores(req, res) {
    try {
        // First, get the top store IDs
        const storeCounts = await Order.aggregate([
            { $match: { status: { $ne: 'cancelled' } } },
            { $group: { _id: '$store', orderCount: { $sum: 1 } } },
            { $sort: { orderCount: -1 } },
            { $limit: 5 }
        ]);

        const storeIds = storeCounts.map(item => item._id);
        // Then, fetch details for these stores
        const storesDetails = await getStoreDetails(storeIds);

        res.status(200).json(storesDetails);
    } catch (error) {
        console.error("Error in getTopStoresWithDetails:", error);
        res.status(500).json({ error: 'Internal server error' });
    }
}
export async function getStoresWithDiscountedProducts(req, res) {
    try {
        const currentDate = new Date();
        const storesWithDiscounts = await Product.aggregate([
            {
                $match: {
                    discount: { $gt: 0 },
                    discountStartDate: { $lte: currentDate },
                    discountEndDate: { $gte: currentDate }
                }
            },
            {
                $lookup: {
                    from: 'stores', // Adjust based on your collection name
                    localField: 'storeId',
                    foreignField: '_id',
                    as: 'storeDetails'
                }
            },
            {
                $unwind: '$storeDetails' // Deconstructs the array field from the $lookup stage into separate documents for each store
            },
            {
                $group: {
                    _id: '$storeId',
                    storeName: { $first: '$storeDetails.storeName' },
                    description: { $first: '$storeDetails.description' },
                    rating: { $first: '$storeDetails.rating' },
                    profileImage: { $first: '$storeDetails.profileImage' }
                }
            },
            {
                $project: {
                    storeId: '$_id',  // Retain _id under the name 'storeId'
                    _id: 1,  // Also include the original _id
                    storeName: 1,
                    description: 1,
                    rating: { $toString: "$rating" }, // Converting rating to a string
                    profileImage: 1
                }
            },
            {
                $sort: { storeName: 1 } // Optional sorting by store name
            }
        ]);

        if (!storesWithDiscounts.length) {
            return res.status(404).json({ status: 'error', message: 'No stores with discounted products found.' });
        }
        res.status(200).json({ status: 'success', message: 'Stores with discounted products fetched successfully.', data: storesWithDiscounts });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Error fetching stores with discounted products: ${error.message}` });
    }
}