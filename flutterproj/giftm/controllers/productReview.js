
import Order from '../models/orderModel.js';
import ProductReview from '../models/productReviewModel.js';
import Product from '../models/productModel.js';
import StoreReview from '../models/storeReviewModel.js';
import Store from '../models/storeModel.js';

export async function verifyDeliveredOrder(req, res) {
    const userId = req.user?.userId;
    const { productId } = req.params;

    try {
        const order = await Order.findOne({
             user: userId,
              "items.product": productId,
              status: 'delivered'
        });

        if (order) {
            res.json({ isDelivered: true });
        } else {
            res.status(403).send("No delivered order found for this product.");
        }
    } catch (error) {
        console.error("Verification failed:", error);
        res.status(500).send("Internal Server Error");
    }
}

// API Endpoint to add a product review
export async function addProductReview(req, res) {
    const userId = req.user?.userId;
    const {id } = req.params;
    const { rating, comment } = req.body;
console.log(req.params);
    try {
        // Check again if the user has already reviewed this product
        const existingReview = await ProductReview.findOne({ user: userId, product: id });
        if (existingReview) {
            return res.status(400).send("You have already reviewed this product.");
        }

        // Create a new review
        const newReview = new ProductReview({
            product: id,
            user: userId,
            rating,
            comment
        });

        await newReview.save();
        updateProductRating(id);


        res.status(201).send("Review added successfully.");
    } catch (error) {
        console.error("Failed to add review:", error);
        res.status(500).send("Internal Server Error");
    }
}

export async function getProductReviews(req, res) {
    const { productId } = req.params;
    try {
        const reviews = await ProductReview.find({ product: productId })
            .populate('user', 'username')  // Assuming 'username' is the field you want
            .sort({ createdAt: -1 }) // Sorting by createdAt descending
            .exec(); // Execute the query

        res.json(reviews.map(review => ({
            comment: review.comment,
            rating: review.rating,
            user: review.user.username,  // Include the username in the response
            createdAt: review.createdAt
        })));
    } catch (error) {
        console.error("Failed to retrieve reviews:", error);
        res.status(500).send("Internal Server Error");
    }
};

async function updateProductRating(productId) {
    try {
        // Retrieve all reviews for the product
        const reviews = await ProductReview.find({ product: productId });

        // Calculate the average rating
        const averageRating = reviews.reduce((acc, cur) => acc + cur.rating, 0) / reviews.length;

        // Update the product's rating
        await Product.findByIdAndUpdate(productId, { rating: averageRating });

        console.log(`Updated product ${productId} with new average rating: ${averageRating}`);
    } catch (error) {
        console.error("Error updating product rating:", error);
    }
}





export async function addStoreReview(req, res) {
    
    const {storeId} = req.params;
    const userId = req.user?.userId;
    const {rating, comment } = req.body;
    
    try {
        const existingReview = await StoreReview.findOne({ store: storeId, user: userId });
        if (existingReview) {
            return res.status(400).json({ message: 'You have already reviewed this store.' });
        }

        const newReview = new StoreReview({
            store: storeId,
            user: userId,
            rating,
            comment
        });

        await newReview.save();

        const store = await Store.findById(storeId);
        if (store) {
            const reviews = await StoreReview.find({ store: storeId });
            const totalRating = reviews.reduce((sum, review) => sum + review.rating, 0);
            store.rating = totalRating / reviews.length;
            await store.save();
        }

        res.status(201).json(newReview);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
};

export async function getStoreReviews(req, res) {
    const storeId = req.store?.storeId; // تأكد من أن هذا الجزء يحصل على storeId بشكل صحيح

    try {
        const reviews = await StoreReview.find({ store: storeId })
            .populate('user', 'username userProfileInfo userPicture createdAt')
            .exec();

        res.status(200).json(reviews);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error });
    }
}
