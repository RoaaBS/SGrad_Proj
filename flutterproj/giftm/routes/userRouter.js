// Import necessary modules
import express from 'express';
import {registerUser,LoginUser} from '../controllers/userRegController.js';
import { resetPassword,requestPasswordReset} from '../controllers/userController.js';
import {verifyToken} from '../middleware/verifyToken.js';
import {addProduct,updateProduct,deleteProduct,addOffer,addOfferCat,getProductsByCategory,
        getProductById} from '../controllers/productController.js';

import {updatePhoneNumber, updateUsername, updateUserImage, getStoreProfile, getUserType, getUserAddress} from '../controllers/userProfileController.js';
import {getCustomerProfile} from '../controllers/customerController.js';

import _ from 'jsonwebtoken';
import { addStore, getStoresByUserId, authenticateStore,getallStores,getAllProductsByStore,getStoreInfo} from '../controllers/ownerController.js';
import {getProducts, getAllProducts, getBestSellingStores,getStoresWithDiscountedProducts} from '../controllers/homeController.js';
import {addToFavorites, removeFromFavorites, getFavorites} from '../controllers/favoriteController.js';

import {addToCart, fetchCart, decrementProductQuantity, incrementProductQuantity,deleteProductFromCart, getCartCount} from '../controllers/cartController.js';
import {getDiscountedProducts, getAllDiscountedProducts} from '../controllers/discountController.js';
import {addCreditCard, fetchCreditCards, getCardById} from '../controllers/cardController.js';
import {getNotifications,getNotificationCount,markAllNotificationsAsRead,getNotifications_S,getNotification_SCount} from '../controllers/NotificationController.js';
import {addOrder, getUserOrder, cancelOrder, getOrderDetails} from '../controllers/orderController.js';
import { addProductReview, verifyDeliveredOrder, getProductReviews, addStoreReview,getStoreReviews} from '../controllers/productReview.js';
import {getUserPreferredCategory,getStoresByCategory, recommendStoresForUser} from '../controllers/recommended.js'
const router = express.Router();

// Define the route for user registration
router.post('/register', registerUser);
router.post('/Login', LoginUser);
router.post('/forgotpassword', requestPasswordReset);
router.post('/resetpassword', resetPassword);




//user profile routers
router.get('/userProfile', verifyToken, getCustomerProfile);
router.patch('/updateUserName', verifyToken, updateUsername);
router.patch('/updatePhoneNumber', verifyToken, updatePhoneNumber);
router.patch('/updateImage', verifyToken, updateUserImage);
router.get('/storeProfile', verifyToken, getStoreProfile);

router.get('/type', verifyToken, getUserType);
router.get('/address', verifyToken, getUserAddress);

///////////////////////////////////////////////////////////////////
router.post('/addStore', verifyToken, addStore);
router.get('/stores', verifyToken, getStoresByUserId);
router.get('/allStore',verifyToken,getallStores);
router.post('/authStore', authenticateStore);
// Assuming this route should handle the URL structure you provided
router.get('/storeproducts/:storeId', getAllProductsByStore);
router.get('/storeInfo/:storeId', verifyToken, getStoreInfo);
//////////////////////////////////////////////////////////////////

// router.post('/add', verifyToken, addProduct);
// router.put('/updateprod/:id',verifyToken, updateProduct);
// router.delete('/deleteprod/:id',verifyToken, deleteProduct);
// router.post('/addOffer/:id', verifyToken, addOffer);
// router.post('/addOfferCat', verifyToken, addOfferCat);
// router.get('/Product/:category',verifyToken,getProductsByCategory);

router.get('/ProductId/:id',verifyToken,getProductById);
router.get('/productList', verifyToken,getProducts);
router.get('/products', verifyToken,getAllProducts);

//////////////Favorite/////////////////
router.post('/addFave/:id', verifyToken, addToFavorites);
router.delete('/deleteFave', verifyToken, removeFromFavorites);
router.get('/getFavorites', verifyToken, getFavorites);

router.post('/addCart', verifyToken, addToCart);
router.get('/getCart', verifyToken, fetchCart);
router.post('/cart/inc', verifyToken, incrementProductQuantity);
router.post('/cart/dec', verifyToken, decrementProductQuantity);
router.post('/cart/delete', verifyToken, deleteProductFromCart);
router.get('/cart/count', verifyToken, getCartCount);

router.get('/discountGet',getDiscountedProducts);
router.get('/allDiscount',getAllDiscountedProducts);
///////////////////
router.post('/cards/add', verifyToken, addCreditCard);
router.get('/cards', verifyToken, fetchCreditCards);
router.get('/cards/:id', verifyToken,getCardById);

//Notification 
router.get('/Notification', verifyToken, getNotifications);
router.get('/Notification_S/:storeId', verifyToken, getNotifications_S);
router.get('/getNotificationCount', verifyToken, getNotificationCount);
router.get('/getNotification_SCount', verifyToken, getNotification_SCount);
router.put('/markAllNotificationsAsRead', verifyToken, markAllNotificationsAsRead);

router.get('/getUserOrder',verifyToken,getUserOrder);
router.post('/createOrder',verifyToken,addOrder);
router.post('/cancelOrder',verifyToken,cancelOrder);
router.get('/getOrderDetails/:id',verifyToken,getOrderDetails);

router.post('/products/:id/reviews',verifyToken,addProductReview);
router.get('/verifyOrder/:productId',verifyToken,verifyDeliveredOrder);

router.get('/getProductReviews/:productId',verifyToken,getProductReviews);
router.get('/store/reviews', verifyToken,getStoreReviews);

router.post('/addStoreReview/:storeId',verifyToken,addStoreReview);

router.get('/BestSelling',getBestSellingStores);

router.get('/discountedStores',getStoresWithDiscountedProducts);

router.get('/getPrefCat',verifyToken,getUserPreferredCategory);

router.get('/getStoresByCat',verifyToken,getStoresByCategory);

router.get('/recommendStores',verifyToken,recommendStoresForUser);

// Export the router
export default router;
