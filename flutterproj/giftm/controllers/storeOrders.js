import Product from '../models/productModel.js';
import Order from '../models/orderModel.js';
import Cart from '../models/cartModel.js';
import User from '../models/userModel.js';
import Store from '../models/storeModel.js';

export async function getStoreOrders(req, res) {
    const storeId = req.store?.storeId;

    if (!storeId) {
        return res.status(403).send('Store ID is required');
    }

    try {
        // Fetch all orders for the specified store with the necessary fields populated
        const orders = await Order.find({ store: storeId })
            .populate({
                path: 'user',
                select: 'username email' // Fetching basic user details
            })
            .populate({
                path: 'items.product',
                select: 'name price' // Fetching product name and price from Product model
            });

        if (!orders.length) {
            return res.status(404).send('No orders found for this store');
        }

        const orderSummaries = orders.map(order => {
            const username = order.user ? order.user.username : 'Unknown';
            return {
                orderId: order._id,
                user: username,
                createdAt: order.createdAt,
                status: order.status,
                address: order.address,
                total: order.total,
                paymentType: order.PaymentType,
                deliveryType: order.DeliveryType,
                itemDetails: order.items.map(item => ({
                    productName: item.product.name,
                    price: item.product.price
                }))
            };
        });
        

        res.json(orderSummaries);
    } catch (error) {
        console.error('Server error:', error);
        res.status(500).send('Server error');
    }
};

// Assuming you're using Express
export async function updateOrderStatus(req, res) {
    const { orderId, status } = req.body;
    if (!orderId || !status) {
      return res.status(400).send('Order ID and Status are required');
    }
  
    try {
      const order = await Order.findByIdAndUpdate(
        orderId,
        { status: status },
        { new: true }
      );
      if (!order) {
        return res.status(404).send('Order not found');
      }
      res.json(order);
    } catch (error) {
      console.error('Failed to update order status:', error);
      res.status(500).send('Internal Server Error');
    }
  };
  
  // Fetch a single order detail for a store
export async function getStoreOrderDetails(req, res) {
  const { id } = req.params;
  const storeId = req.store?.storeId;

  if (!storeId) {
      return res.status(403).send('Store authentication required');
  }

  try {
      const order = await Order.findById(id)
          .populate({
              path: 'user',
              select: 'username email'
          })
          .populate({
            path: 'items.product', 
            select: 'productName price image discount'
        });

      if (!order) {
          return res.status(404).send('Order not found');
      }

      res.json({
          orderId: order._id,
          user: {
              username: order.user.username,
              email: order.user.email
          },
          createdAt: order.createdAt,
          status: order.status,
          address: order.address,
          total: order.total,
          paymentType: order.PaymentType,
          deliveryType: order.DeliveryType,
          items: order.items.map(item => ({
            productName: item.product.productName,
            price: item.product.price,
            image: item.product.image,
            quantity: item.quantity,
            
        })),
      });
  } catch (error) {
      console.error('Server error:', error);
      res.status(500).send('Internal Server Error');
  }
};
