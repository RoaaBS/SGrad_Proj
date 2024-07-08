import mongoose from 'mongoose';

// Define the Card schema
const cardSchema = new mongoose.Schema({
    cardNumber: {
        type: String,
        required: true
    },
    cardHolderName: {
        type: String,
        required: true
    },
    expirationDate: {
        type: String,
        required: true
    },
    cvv: {
        type: String,
        required: true
    },
    billingAddress: {
        type: String,
        default: null
    },
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    lastFourDigits: {
        type: String,
        required: true
    }
});

const Card = mongoose.model('Card', cardSchema);
export default Card;