import _express from 'express';
import _mongoose from 'mongoose';
import _crypto from 'crypto';
import Favorite from '../models/favoriteModel.js';

export async function addToFavorites(req, res) {
    const userId = req.user?.userId;
    const productId = req.params.id;

    if (!userId) {
        return res.status(403).json({ status: 'error', message: 'Access denied. No user associated with this token.' });
    }

    if (!productId) {
        return res.status(400).json({ status: 'error', message: 'Product ID must be provided.' });
    }

    try {
        const existingFavorite = await Favorite.findOne({ userId, productId });
        if (existingFavorite) {
            return res.status(409).json({ status: 'error', message: 'Product already added to favorites.' });
        }

        const newFavorite = new Favorite({ userId, productId });
        await newFavorite.save();
        res.status(201).json({
            status: 'success',
            message: 'Product added to favorites successfully.',
            favorite: newFavorite
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to add to favorites: ${error.message}` });
    }
}



export async function removeFromFavorites(req, res) {
    const userId = req.user?.userId;
    const { productId } = req.body;

    if (!userId) {
        return res.status(403).json({ status: 'error', message: 'Access denied. No user associated with this token.' });
    }

    if (!productId) {
        return res.status(400).json({ status: 'error', message: 'Product ID must be provided.' });
    }

    try {
        const favorite = await Favorite.findOneAndDelete({ userId, productId });
        if (!favorite) {
            return res.status(404).json({ status: 'error', message: 'Favorite not found.' });
        }

        res.status(200).json({
            status: 'success',
            message: 'Product removed from favorites successfully.'
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to remove from favorites: ${error.message}` });
    }
}

// Get all favorite products for a user
export async function getFavorites(req, res) {
    const userId = req.user?.userId;

    if (!userId) {
        return res.status(403).json({ status: 'error', message: 'Access denied. No user associated with this token.' });
    }

    try {
        const favorites = await Favorite.find({ userId }).populate('productId');
        const productIds = favorites.map(fav => fav.productId);
        res.status(200).json({
            status: 'success',
            favorites: productIds
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to fetch favorites: ${error.message}` });
    }
}


