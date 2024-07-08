// ProductModel.js
import mongoose from 'mongoose';

const productSchema = new mongoose.Schema({
    storeId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Store',
        required: true
    },
    productName: {
        type: String,
        required: true
    },
    description: {
        type: String,
        required: true
    },
    price: {
        type: Number,
        required: true
    },
    quantity: {
        type: Number,
        required: true
    },
    image: {
        type: String,
        required: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    },
    discount: {
        type: Number,
        min: 0,
        max: 100,
        default: 0
    },
    discountStartDate: {
        type: Date, 
        default: 0 
    },
    discountEndDate: {
        type: Date, 
        default: 0 
    },
    category: {
        type: String,
        required: true
    },
    rating: {
        type: Number,
        min: 0,
        max: 5,
        default: 0  // Sets the default rating to 0
    }
});

const Product = mongoose.model('Product', productSchema);

export default Product;
