import Product from '../models/productModel.js';
import Order from '../models/orderModel.js';
import Cart from '../models/cartModel.js';
import Store from '../models/storeModel.js';
import Notification from '../models/NotificationModel.js';
import User from '../models/userModel.js';

/**
 * Adds a new order to the system and handles notifications.
 * @param {Object} req HTTP request object.
 * @param {Object} res HTTP response object.
 */
export async function addOrder(req, res) {
    const userId = req.user?.userId;
    const { total, PaymentType, address, DeliveryType, packaging } = req.body;
    console.log("Creating Order:", total, PaymentType, address, DeliveryType, packaging);

    try {
        const cart = await Cart.findOne({ user: userId }).populate('items.product');
        if (!cart) {
            return res.status(404).send('Cart not found');
        }

        // Verify product availability
        for (const item of cart.items) {
            try {
                const product = await Product.findById(item.product);
                if (!product) {
                    return res.status(404).send(`Product not found for id ${item.product}`);
                }
                if (product.quantity < item.quantity) {
                    return res.status(400).send(`Insufficient stock for product ${product.productName}`);
                }
            } catch (error) {
                console.error(`Error fetching product ${item.product}:`, error);
                return res.status(500).send(`Error fetching product ${item.product}: ${error.message}`);
            }
        }

        // Create the order with additional fields
        const order = new Order({
            user: userId,
            store: cart.items[0].product.storeId,  // Assuming all items are from the same store
            items: cart.items.map(item => ({
                product: item.product,
                quantity: item.quantity
            })),
            total: total,
            status: 'pending',
            PaymentType: PaymentType,
            DeliveryType: DeliveryType,  // Delivery type from the request
            packaging: packaging,  // Packaging option from the request
            address: address
        });

        await order.save();

        // Deduct quantities from products and clear the cart only if the order is saved successfully
        await Promise.all(cart.items.map(async item => {
            try {
                await Product.findByIdAndUpdate(item.product, { $inc: { quantity: -item.quantity }});
            } catch (error) {
                console.error(`Error deducting quantity for product ${item.product}:`, error);
                return res.status(500).send(`Error deducting quantity for product ${item.product}: ${error.message}`);
            }
        }));

        await Cart.updateOne({ user: userId }, { $set: { items: [] } });

        // Send notifications
        const store = await Store.findById(cart.items[0].product.storeId);
        if (!store) {
            return res.status(404).send('Store not found.');
        }

        // Send notification to users about new order
        const notificationMessage = `تم استلام طلب جديد من قبل العميل.`;
        await Promise.all(cart.items.map(async item => {
            try {
                const product = await Product.findById(item.product);
                const users = await User.find({});
                await Promise.all(users.map(async user => {
                    try {
                        const notification = new Notification({
                            receiverId: store._id,
                            senderId: user._id,
                            senderName: 'نظام الطلبات',
                            type: 'New Order',  // <-- Ensure type is set appropriately
                            senderPicture: store.profileImage,
                            content: notificationMessage,
                            isRead: false
                        });
                        await notification.save();
                        console.log(`Notification created for user ${user._id}`);
                    } catch (error) {
                        console.error(`Failed to create notification for user ${user._id}:`, error);
                    }
                }));
            } catch (error) {
                console.error(`Error processing notification for item ${item.product}:`, error);
            }
        }));

        // Send notification to store owner if any product quantity is less than 30
        await Promise.all(cart.items.map(async item => {
            try {
                const product = await Product.findById(item.product);
                if (product.quantity < 30) {
                    const notificationMessage = `يوجد كمية قليلة من المنتج ${product.productName} في متجرك ${store.storeName}.`;
                    try {
                        const notification = new Notification({
                            receiverId: store._id,
                            senderId: userId,
                            senderName: 'نظام الطلبات',
                            type: 'Low Stock',  // <-- Ensure type is set appropriately
                            content: notificationMessage,
                            senderPicture: store.profileImage,
                            isRead: false
                        });
                        await notification.save();
                        console.log(`Notification created for store owner ${store.ownerId}`);
                    } catch (error) {
                        console.error(`Failed to create notification for store owner ${store.ownerId}:`, error);
                    }
                }
            } catch (error) {
                console.error(`Error processing low stock notification for item ${item.product}:`, error);
            }
        }));

        res.status(200).json({
            status: 'success',
            message: 'تم إنشاء الطلب بنجاح مع إرسال الإشعارات.',
            order: order
        });
    } catch (error) {
        console.error('Server error:', error);
        res.status(500).send('Server error: ' + error.message);
    }
};

/**
 * Fetches orders for a specific user.
 * @param {Object} req HTTP request object.
 * @param {Object} res HTTP response object.
 */
export async function getUserOrder(req, res) {
    const userId = req.user?.userId; // Ensure authentication middleware sets this

    if (!userId) {
        return res.status(403).send('User ID is required');
    }

    try {
        const orders = await Order.find({ user: userId })
            .populate({
                path: 'store',
                select: 'storeName',
            });
    
        const orderSummaries = orders.map(order => {
            return {
                orderId: order._id,
                storeName: order.store ? order.store.storeName : 'Store Deleted or Not Found',
                createdAt: order.createdAt,
                status: order.status,
                address: order.address,
                total: order.total,
                PaymentType: order.PaymentType
            };
        });
    
        res.json(orderSummaries);
    } catch (error) {
        console.error('Server error:', error);
        res.status(500).send('Server error');
    }
};

/**
 * Cancels an existing order.
 * @param {Object} req HTTP request object.
 * @param {Object} res HTTP response object.
 */
export async function cancelOrder(req, res) {
    const { orderId } = req.body;
    const userId = req.user?.userId;

    if (!orderId) {
        return res.status(400).send('Order ID is required');
    }

    try {
        const order = await Order.findById(orderId);

        if (!order) {
            return res.status(404).send('Order not found');
        }

        if (order.user.toString() !== userId.toString()) {
            return res.status(403).send('Unauthorized to cancel this order');
        }

        const timeElapsed = new Date() - order.createdAt;
        if (order.status === 'pending' && timeElapsed < 24 * 60 * 60 * 1000) {
            order.status = 'cancelled';
            await order.save();
            res.send('Order has been cancelled');
        } else {
            res.status(400).send('Order cannot be cancelled');
        }
    } catch (error) {
        console.error('Server error:', error);
        res.status(500).send('Server error');
    }
};

/**
 * Retrieves details of a specific order.
 * @param {Object} req HTTP request object.
 * @param {Object} res HTTP response object.
 */
export async function getOrderDetails(req, res) {
    const { id } = req.params;

    try {
        const order = await Order.findById(id)
            .populate({
                path: 'store',
                select: 'storeName'
            })
            .populate({
                path: 'items.product',
                select: 'productName price image discount'
            });

        if (!order) {
            return res.status(404).send('Order not found');
        }

        // Modify the order object to include product details in the response
        const orderResponse = {
            orderId: order._id,
            user: order.user,
            store: order.store,
            items: order.items.map(item => ({
                productId: item.product._id,
                productName: item.product.productName,
                price: item.product.price,
                image: item.product.image,
                discount: item.product.discount,
                
            })),
            total: order.total,
            status: order.status,
            createdAt: order.createdAt,
            PaymentType: order.PaymentType,
            address: order.address
        };

        res.json(orderResponse);
    } catch (error) {
        console.error('Server error:', error);
        res.status(500).send('Server error');
    }
};
