import _express from 'express';
import _mongoose from 'mongoose';
import Product from '../models/productModel.js';

/**
 * @param {Object} req HTTP request object.
 * @param {Object} res HTTP response object.
 */ 


export async function getDiscountedProducts(req, res) {
    try {
        const currentDate = new Date();
        const discountedProducts = await Product.find({
            discount: { $gt: 0 },
            discountStartDate: { $lte: currentDate },
            discountEndDate: { $gte: currentDate }
        }).sort({ createdAt: -1 }).limit(10);

        if (!discountedProducts) {
            return res.status(404).json({ status: 'error', message: 'No discounted products found.' });
        }
        res.status(200).json({ status: 'success', message: 'Discounted products fetched successfully.', data: discountedProducts });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Error fetching discounted products: ${error.message}` });
    }
}

export async function getAllDiscountedProducts(req, res) {
    try {
        const currentDate = new Date();
        const discountedProducts = await Product.find({
            discount: { $gt: 0 },
            discountStartDate: { $lte: currentDate },
            discountEndDate: { $gte: currentDate }
        }).sort({ createdAt: -1 });

        if (!discountedProducts) {
            return res.status(404).json({ status: 'error', message: 'No discounted products found.' });
        }
        res.status(200).json({ status: 'success', message: 'Discounted products fetched successfully.', data: discountedProducts });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Error fetching discounted products: ${error.message}` });
    }
}