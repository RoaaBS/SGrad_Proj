import _ from 'jsonwebtoken';
import express from 'express';
import {verifyToken} from '../middleware/verifyToken.js';

import {
  addProduct,
  updateProduct,
  deleteProduct,
  addOffer,
  addOfferCat,
  getProductsByCategory,
  getProductById,
  getMostSoldProducts,
  getSoldProducts,
} from "../controllers/productController.js";
import {updateStoreImage} from '../controllers/ownerController.js';

import { getUnverifiedStoresWithLicenseImage } from '../controllers/StoreController.js';
import{getStoreNearMe, getStoreRating} from '../controllers/homeController.js'
// import { getStoreProfile } from '../controllers/storeProfileController.js';

import{getStoreOrders,updateOrderStatus,getStoreOrderDetails} from '../controllers/storeOrders.js';
import {getSalesPerformance, getYearlySalesPerformance, getbarYearlySalesPerformance} from '../controllers/storeSales.js';


import {  getStoreProfile,updateStoreName, updateStorePhoneNumber, updateStoreProfileImage} from '../controllers/storeProfileController.js';
const router = express.Router();


router.post('/addProduct', verifyToken, addProduct);
router.get("/mostsoldproducts", verifyToken, getMostSoldProducts);
router.get("/soldproducts", verifyToken, getSoldProducts);
router.get('/Product/:category',verifyToken,getProductsByCategory);
router.post('/addOfferCat', verifyToken, addOfferCat);
router.get('/ProductId/:id', getProductById);
router.put('/updateprod/:id',verifyToken, updateProduct);
router.delete('/deleteprod/:id',verifyToken, deleteProduct);
router.post('/addOffer/:id', verifyToken, addOffer);
router.get('/storerating', getStoreRating);

router.patch('/updateStoreName', verifyToken, updateStoreName);
router.patch('/updateStorePhoneNumber', verifyToken, updateStorePhoneNumber);
router.patch('/updateStoreProfileImage',verifyToken,updateStoreProfileImage);
router.get('/storeProfile', verifyToken, getStoreProfile);

router.get('/storeorders',verifyToken,getStoreOrders);
router.post('/updateStatus',verifyToken,updateOrderStatus);
router.get('/storeorders/:id',verifyToken,getStoreOrderDetails);
router.get('/getStoreNearMe',getStoreNearMe);

router.get('/performance',verifyToken, getSalesPerformance);
router.get('/yearlysalesperformance',verifyToken, getYearlySalesPerformance);
router.get('/yearbarlysalesperformance',verifyToken, getbarYearlySalesPerformance);
router.get('/unverified-stores', getUnverifiedStoresWithLicenseImage);
router.put('/storeImage',verifyToken,updateStoreImage);


// router.get('/Topstores',getTopStoreIDs);

// router.get('/storedetails',getStoreDetails);




export default router;