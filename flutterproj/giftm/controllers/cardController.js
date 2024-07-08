import mongoose from 'mongoose';
import User from '../models/userModel.js';
import Card from '../models/cardModel.js';

export async function addCreditCard(req, res) {
    const userId = req.user?.userId;
    const { cardNumber, cardHolderName, expirationDate, cvv, billingAddress } = req.body;

    if (!userId) {
        return res.status(403).json({ status: 'error', message: 'Access denied. No user associated with this token.' });
    }

    if (!cardNumber || !cardHolderName || !expirationDate || !cvv) {
        return res.status(400).json({ status: 'error', message: 'All credit card fields must be provided.' });
    }

    try {
        // Check if the card is already added by the user
        const existingCard = await Card.findOne({ userId, cardNumber });
        if (existingCard) {
            return res.status(409).json({ status: 'error', message: 'Card already added to your account.' });
        }

        // Create a new card
        const lastFourDigits = cardNumber.slice(-4);
        const newCard = new Card({
            cardNumber, // You might want to encrypt this field
            cardHolderName,
            expirationDate,
            cvv, // You might want to encrypt this field
            billingAddress,
            userId,
            lastFourDigits
        });

        await newCard.save();

        // Add card to the user's cards array
        await User.findByIdAndUpdate(userId, { $push: { cards: newCard._id } });

        res.status(201).json({
            status: 'success',
            message: 'Credit card added successfully.',
            card: newCard
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to add credit card: ${error.message}` });
    }
}

export async function fetchCreditCards(req, res) {
    const userId = req.user?.userId;  // Assuming 'userId' is extracted from the token

    if (!userId) {
        return res.status(403).json({ status: 'error', message: 'Access denied. No user associated with this token.' });
    }

    try {
        const cards = await Card.find({ userId }).select('-cvv -cardNumber'); // Exclude sensitive information like CVV and full card number

        if (cards.length === 0) {
            return res.status(404).json({ status: 'error', message: 'No credit cards found.' });
        }

        res.status(200).json({
            status: 'success',
            message: `Credit cards retrieved successfully.`,
            cards: cards.map(card => ({
                _id: card._id,
                cardHolderName: card.cardHolderName,
                expirationDate: card.expirationDate,
                lastFourDigits: card.lastFourDigits,
            }))
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to fetch credit cards: ${error.message}` });
    }
}

export async function getCardById(req, res) {
    try {
        const userId = req.user?.userId;
        const cardId = req.params.id;

    if (!userId) {
        return res.status(403).json({ status: 'error', message: 'Access denied. No user associated with this token.' });
    }
      const card = await Card.findById(cardId);
      if (!card) {
        return res.status(404).json({ message: 'Card not found' });
      }
      res.status(200).json(card);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  };