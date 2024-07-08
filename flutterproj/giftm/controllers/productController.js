// controllers/productController.js
import Product from '../models/productModel.js';
import Store from '../models/storeModel.js';
import Notification from '../models/NotificationModel.js'; 
import User from '../models/userModel.js';
import Order from '../models/orderModel.js';
import mongoose from 'mongoose';
import Favorite from '../models/favoriteModel.js';

/**
 * Adds a new product to the store using the store owner's ID extracted from the JWT token.
 * @param {Object} req HTTP request object.
 * @param {Object} res HTTP response object.
 */
export async function addProduct(req, res) {
    const { productName, description, price, quantity, image, category } = req.body;

    // Use store ID from the verified token
    const storeId = req.store?.storeId;
    if (!storeId) {
        return res.status(403).json({ status: 'error', message: 'Access denied. No store associated with this token.' });
    }

    if (!productName || !description || !price || !quantity || !image || !category) {
        return res.status(400).json({ status: 'error', message: 'All product fields must be filled.' });
    }

    try {
        const newProduct = new Product({
            storeId,  // Use the store ID from the token
            productName,
            description,
            price,
            quantity,
            image,
            category,
            rating: 0
        });

        await newProduct.save();
        res.status(201).json({
            status: 'success',
            message: 'Product added successfully.',
            product: newProduct
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to add product: ${error.message}` });
    }
}

/**
 * Update a  product to the store using the product ID 
 * @param {Object} req HTTP request object.
 * @param {Object} res HTTP response object.
 */

export async function updateProduct(req, res) {
    const productId = req.params.id;

    try {
        const updatedProduct = await Product.findByIdAndUpdate(productId, req.body, { new: true });

        if (!updatedProduct) {
            return res.status(404).json({ status: 'error', message: 'Product not found.' });
        }

        res.status(200).json({
            status: 'success',
            message: 'Product updated successfully.',
            product: updatedProduct
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to update product: ${error.message}` });
    }
}

/**
 * Delete a  product to the store using the product ID 
 * @param {Object} req HTTP request object.
 * @param {Object} res HTTP response object.
 */

export async function deleteProduct(req, res) {
    const productId = req.params.id;

    try {
        const deletedProduct = await Product.findByIdAndDelete(productId);

        if (!deletedProduct) {
            return res.status(404).json({ status: 'error', message: 'Product not found.' });
        }

        res.status(200).json({
            status: 'success',
            message: 'Product deleted successfully.',
            product: deletedProduct
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to delete product: ${error.message}` });
    }
}




/**
 * add offer to the store using the product ID 
 * @param {Object} req HTTP request object.
 * @param {Object} res HTTP response object.
 */


   
export async function addOffer(req, res) {
    const productId = req.params.id;
    const { discount, discountStartDate, discountEndDate } = req.body;

    try {
        const startDate = new Date(discountStartDate);
        const endDate = new Date(discountEndDate);

        if (startDate >= endDate) {
            return res.status(400).json({ status: 'error', message: 'Discount start date must be before the end date.' });
        }

        const product = await Product.findById(productId);
        if (!product) {
            return res.status(404).json({ status: 'error', message: 'Product not found.' });
        }

        const discountValue = parseFloat(discount);
        if (isNaN(discountValue) || discountValue < 0 || discountValue > 100) {
            return res.status(400).json({ status: 'error', message: 'Invalid discount value. Please enter a percentage between 0 and 100.' });
        }

        const originalPrice = product.price;
        const discountedPrice = originalPrice * (1 - discountValue / 100);

        const updatedProduct = await Product.findByIdAndUpdate(productId, {
            discount: discountValue,
            discountStartDate: startDate,
            discountEndDate: endDate,
            discountedPrice: discountedPrice,
        }, { new: true });

        console.log('Original price:', originalPrice);
        console.log('Discounted price:', discountedPrice);

        const store = await Store.findById(product.storeId);
        if (!store) {
            return res.status(404).json({ status: 'error', message: 'Store not found.' });
        }

        const users = await User.find({});
        console.log(`${users.length} users found.`);

        await Promise.all(users.map(async user => {
            const notificationMessage = `لقد تلقيت عرض خصم جديد من ${store.storeName} على ${product.productName}.`;

            console.log(`Creating notification for user ${user._id}`);

            try {
                const notification = new Notification({
                    receiverId: user._id,
                    senderId: store._id,
                    senderName: store.storeName,
                    type: 'Discount Alert',
                    content: notificationMessage,
                    senderPicture: store.profileImage,
                    isRead: false
                });

                console.log(`Notification data: ${JSON.stringify(notification)}`);
                await notification.save();
                console.log(`Notification created for user ${user._id}`);
            } catch (error) {
                console.error(`Failed to create notification for user ${user._id}:`, error);
            }
        }));

        res.status(200).json({
            status: 'success',
            message: 'Product updated successfully with discount and notifications sent.',
            product: {
                ...updatedProduct.toObject(),
                originalPrice,
                discountedPrice
            }
        });
    } catch (error) {
        console.error('Failed to update product or send notifications:', error);
        res.status(500).json({ status: 'error', message: `Failed to update product or send notifications: ${error.message}` });
    }
}



/**
* add offer  to the store using the category
* @param {Object} req HTTP request object.
* @param {Object} res HTTP response object.
*/

function parseDate(dateStr) {
    return new Date(dateStr); // استخدام Date مباشرة لتحليل تنسيق ISO 8601
}

export async function addOfferCat(req, res) {
    const { category, discount, discountStartDate, discountEndDate } = req.body;
    const storeId = req.store?.storeId;

    if (!storeId) {
        return res.status(403).json({ status: 'error', message: 'Access denied. No store associated with this token.' });
    }

    try {
        const store = await Store.findById(storeId);
        if (!store) {
            return res.status(404).json({ status: 'error', message: 'Store not found.' });
        }

        const startDate = parseDate(discountStartDate);
        const endDate = parseDate(discountEndDate);

        if (isNaN(startDate) || isNaN(endDate)) {
            return res.status(400).json({ status: 'error', message: 'Invalid date format.' });
        }

        if (startDate >= endDate) {
            return res.status(400).json({ status: 'error', message: 'Discount start date must be before the end date.' });
        }

        const discountValue = parseFloat(discount);
        if (isNaN(discountValue) || discountValue < 0 || discountValue > 100) {
            return res.status(400).json({ status: 'error', message: 'Invalid discount value. Must be between 0 and 100.' });
        }

        const products = await Product.find({ category, storeId });
        if (!products.length) {
            return res.status(404).json({ status: 'error', message: `No products found for category "${category}" in this store.` });
        }

        const updates = products.map(product => {
            const discountedPrice = product.price * (1 - discountValue / 100);
            return Product.findByIdAndUpdate(product._id, {
                $set: {
                    discount: discountValue,
                    discountStartDate: startDate,
                    discountEndDate: endDate,
                    discountedPrice: discountedPrice
                }
            }, { new: true });
        });

        const updatedProducts = await Promise.all(updates);
        console.log(`${updatedProducts.length} products updated.`);

        const users = await User.find({});
        console.log(`${users.length} users found.`);

        await Promise.all(users.map(async user => {
            const notificationMessage = `لقد تلقيت عرض خصم جديد من ${store.storeName} على ${category}.`;

            console.log(`Creating notification for user ${user._id}`);

            try {
                const notification = new Notification({
                    receiverId: user._id,
                    senderId: storeId,
                    senderName: store.storeName,
                    type: 'Discount Alert',
                    content: notificationMessage,
                    senderPicture: store.profileImage ,
                    isRead: false
                });

                console.log(`Notification data: ${JSON.stringify(notification)}`);
                await notification.save();
                console.log(`Notification created for user ${user._id}`);
            } catch (error) {
                console.error(`Failed to create notification for user ${user._id}:`, error);
            }
        }));

        res.status(200).json({
            status: 'success',
            message: `Discounts successfully applied to ${updatedProducts.length} products.`,
            products: updatedProducts
        });
    } catch (error) {
        console.error('Failed to apply discounts or send notifications:', error);
        res.status(500).json({ status: 'error', message: `Failed to apply discounts or send notifications: ${error.message}` });
    }
}















/**
 * Get all products from the store based on category
 * @param {Object} req HTTP request object.
 * @param {Object} res HTTP response object.
 */

export async function getProductsByCategory(req, res) {
    const category = req.params.category;
    const storeId = req.store?.storeId;  // Extract store ID from the token

    if (!storeId) {
        return res.status(403).json({ status: 'error', message: 'Store ID is required.' });
    }

    try {
        const products = await Product.find({ storeId, category });  // Include storeId in the query
        if (products.length === 0) {
            return res.status(404).json({ status: 'error', message: `No products found in category: ${category} for the given store.` });
        }
        res.status(200).json({
            status: 'success',
            message: `Products found in category: ${category} for store ID: ${storeId}.`,
            products
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to get products: ${error.message}` });
    }
}



/**
 * Get all products from the store based on id
 * @param {Object} req HTTP request object.
 * @param {Object} res HTTP response object.
 */
export async function getProductById(req, res) {
    const productId = req.params.id;
    const userId = req.user?.userId;

    try {
        const product = await Product.findById(productId)
            .populate({
                path: 'storeId',
                select: 'storeName profileImage'
            });

        if (!product) {
            return res.status(404).json({ status: 'error', message: `Product not found with ID: ${productId}.` });
        }

        const isFavorite = await checkIfFavorite(userId, productId);

        const response = {
            status: 'success',
            message: `Product found with ID: ${productId}.`,
            product: {
                id: product._id,
                productName: product.productName,
                description: product.description,
                price: product.price,
                quantity: product.quantity,
                image: product.image,
                discount: product.discount,
                discountStartDate: product.discountStartDate,
                discountEndDate: product.discountEndDate,
                category: product.category,
                rating: product.rating,
                createdAt: product.createdAt,
                storeDetails: {
                    storeId: product.storeId._id,
                    storeName: product.storeId.storeName,
                    storeImage: product.storeId.profileImage
                },
                isFavorite
            }
        };

        res.status(200).json(response);
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to get product: ${error.message}` });
    }
}


async function checkIfFavorite(userId, productId) {
    const favorite = await Favorite.findOne({ userId, productId });
    return favorite !== null;  // Returns true if the favorite exists, false otherwise
}


/**
 * إضافة منتج إلى قائمة المفضلات
 * @param {Object} req - HTTP request object
 * @param {Object} res - HTTP response object
 */
export async function addtofav(req, res) {
    const productId = req.params.id;

    try {
        // تحقق من وجود المنتج
        const product = await Product.findById(productId);
        if (!product) {
            return res.status(404).json({ status: 'error', message: 'Product not found.' });
        }

        // إضافة المنتج إلى المفضلات إذا لم يكن موجودًا بالفعل في قائمة المفضلات المخزنة
        // فرضيًا نفترض وجود قائمة مفضلات داخل نموذج المنتج نفسه أو في جلسة المستخدم
        if (product.isFavorite) {
            return res.status(409).json({ status: 'error', message: 'Product already in favorites.' });
        }

        // تحديث حالة المفضلة للمنتج
        product.isFavorite = true;
        await product.save();

        res.status(200).json({
            status: 'success',
            message: 'Product added to favorites successfully.',
            product: {
                id: product._id,
                name: product.name,
                isFavorite: product.isFavorite
            }
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to add product to favorites: ${error.message}` });
    }
}

export async function getMostSoldProducts(req, res) {
  const storeId = req.store?.storeId;
  try {
     if (!storeId) {
        return res.status(403).json({ status: 'error', message: 'Access denied. No store associated with this token.' });
    }


    const mostSoldProducts = await Order.aggregate([
      { $match: { store: new mongoose.Types.ObjectId(storeId) } }, // Filter orders by store ID
      { $unwind: "$items" }, // Deconstruct the items array
      {
        $group: {
          _id: "$items.product", // Group by product ID
          totalQuantity: { $sum: "$items.quantity" }, // Sum the quantities
        },
      },
      { $sort: { totalQuantity: -1 } }, // Sort by total quantity in descending order
      {
        $lookup: {
          from: "products", // The collection name in the database
          localField: "_id",
          foreignField: "_id",
          as: "productDetails",
        },
      },
      { $unwind: "$productDetails" }, // Unwind the productDetails array
      {
        $project: {
          productName: "$productDetails.productName",
          description: "$productDetails.description",
          price: "$productDetails.price",
          image: "$productDetails.image",
        },
      },
    ]);


    res.status(200).json({
      status: "success",
      message: `Most sold products found, for store ID: ${storeId}.`,
      mostSoldProducts,
    });
  } catch (error) {
    res.status(500).json({
      status: "error",
      message: `Failed to get most sold products for store ID: ${storeId}: ${error.message}`,
    });
    console.error(error);
    throw error;
  }
}

export async function getSoldProducts(req, res) {
    const storeId = req.store?.storeId;
    if (!mongoose.Types.ObjectId.isValid(storeId)) {
      return res.status(400).json({ msg: 'Invalid store ID' });
    }
    try {
      const result = await Order.aggregate([
        { $match: { store: new mongoose.Types.ObjectId(storeId) } },
        { $unwind: '$items' },
        {
          $group: {
            _id: '$items.product',
            totalSold: { $sum: '$items.quantity' }
          }
        },
        {
          $lookup: {
            from: 'products',
            localField: '_id',
            foreignField: '_id',
            as: 'productInfo'
          }
        },
        { $unwind: '$productInfo' },
        {
          $project: {
            _id: 0,
            productName: '$productInfo.productName',
            totalSold: 1
          }
        }
      ]);
  
      const dataMap = result.reduce((map, item) => {
        map[item.productName] = item.totalSold;
        return map;
      }, {});
      console.log("dataMap", dataMap);
      res.status(200).json(dataMap);
    } catch (err) {
      console.error(err.message);
      res.status(500).send('Server Error');
    }
  };