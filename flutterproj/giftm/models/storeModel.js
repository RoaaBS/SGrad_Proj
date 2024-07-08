import mongoose from 'mongoose';

const storeSchema = new mongoose.Schema({
    storeName: {
        type: String,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: false
    },
    phoneNumber: {
        type: String,
        required: true,
        unique: true // Assuming you want the phone number to be unique as well
    },
    email: {
        type: String,
        required: true,
        unique: true  // Ensuring email addresses are unique to each store
    },
    address: {
        type: String,
        default: ''
    },
    city: {
        type: String,
        default: ''
    },
    profileImage: {
        type: String,
        default: null
    },
    description: {
        type: String,
        required: true
    },
    rating: {
        type: mongoose.Schema.Types.Decimal128,
        default: 0.0  
    },
    verified: {
        type: Boolean,
        default: false
    },
    licenseImage: {
        type: String,
        default: '',
    },
    storeOwner: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
   
});

const Store = mongoose.model('Store', storeSchema);

export default Store;