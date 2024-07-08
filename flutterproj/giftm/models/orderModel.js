// OrderModel.js
import mongoose from 'mongoose';
import Product from './productModel.js';

const orderItemSchema = new mongoose.Schema({
    product: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Product',
        required: true
    },
    quantity: {
        type: Number,
        required: true,
        min: 1
    }
});

const orderSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    store: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Store',
        required: true
    },
    items: [orderItemSchema],
    total: {
        type: Number,
        required: true
    },
    status: {
        type: String,
        enum: ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'],
        default: 'pending'
    },
    createdAt: {
        type: Date,
        default: Date.now
    },
    PaymentType: {
        type: String,
        enum: ['Card', 'in person','card','Cash'],
        default: null 
    },
    DeliveryType: {
        type: String,
        enum: ['Delivery', 'in person','delivery','Pickup'],
        default: null 
    },
    packaging: {
        type: Boolean,
        default: false
    },
    
    address:{
        type: String,
    }
});

const Order = mongoose.model('Order', orderSchema);

export default Order;
