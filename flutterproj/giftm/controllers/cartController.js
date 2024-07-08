import Cart from '../models/cartModel.js';
import Product from '../models/productModel.js';

export async function addToCart(req, res) {
    const userId = req.user?.userId;  // Assuming 'userId' is extracted from the token
    const { productId } = req.body;

    if (!userId) {
        return res.status(403).json({ status: 'error', message: 'Access denied. No user associated with this token.' });
    }

    if (!productId) {
        return res.status(400).json({ status: 'error', message: 'Product ID is required.' });
    }

    try {
        // Check if the product exists
        const product = await Product.findById(productId);
        if (!product) {
            return res.status(404).json({ status: 'error', message: 'Product not found.' });
        }

        // Find the cart of the user, or create a new one if it doesn't exist
        const cart = await Cart.findOne({ user: userId });
        if (cart) {
            // Cart exists, check if the product is already in the cart
            const productExists = cart.items.some(item => item.product.toString() === productId);

            if (!productExists) {
                // Product does not exist in the cart, add it
                cart.items.push({ product: productId, quantity: 1 });
                await cart.save();  // Save the updated cart
                res.status(200).json({
                    status: 'success',
                    message: 'Product added to cart successfully.',
                    cart
                });
            } else {
                // Product already exists in the cart, do not add it again
                res.status(409).json({
                    status: 'error',
                    message: 'Product already in cart.'
                });
            }
        } else {
            // No cart exists, create a new one with the product
            const newCart = new Cart({
                user: userId,
                items: [{ product: productId, quantity: 1 }]
            });
            await newCart.save();
            res.status(201).json({
                status: 'success',
                message: 'Product added to new cart successfully.',
                cart: newCart
            });
        }
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to add product to cart: ${error.message}` });
    }
}

export async function fetchCart(req, res) {
    const userId = req.user?.userId;
    if (!userId) {
        return res.status(403).json({ status: 'error', message: 'Access denied. No user associated with this token.' });
    }

    try {
        const cart = await Cart.findOne({ user: userId }).populate('items.product');
        if (!cart) {
            return res.status(404).json({ status: 'error', message: 'Cart not found.' });
        }

        const transformedItems = cart.items.map(item => {
            if (!item.product) {
                return {
                    productId: 'Product not found',
                    productName: 'Product not found',
                    price: 0,
                    originalPrice: null,
                    quantity: item.quantity,
                    image: '',
                    description: 'No description available'
                };
            }

            const { product } = item;
            const now = new Date();
            let price = product.price;
            let originalPrice = null;

            if (product.discount > 0 &&
                new Date(product.discountStartDate) <= now &&
                new Date(product.discountEndDate) >= now) {
                originalPrice = price;  // Save original price before applying discount
                price = price * (1 - product.discount / 100);  // Apply discount
            }

            return {
                productId: product._id,
                productName: product.productName,
                price,
                originalPrice,
                quantity: item.quantity,
                image: product.image,
                description: product.description
            };
        });

        res.status(200).json({
            status: 'success',
            message: 'Cart fetched successfully.',
            items: transformedItems
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Error fetching cart: ${error.message}` });
    }
}


// Increment product quantity in the cart
export async function incrementProductQuantity(req, res) {
    const userId = req.user?.userId;
    const { productId } = req.body;

    if (!userId) {
        return res.status(403).json({ status: 'error', message: 'Access denied. No user associated with this token.' });
    }

    try {
        const cart = await Cart.findOne({ user: userId }).populate('items.product');
        if (!cart) {
            return res.status(404).json({ status: 'error', message: 'Cart not found.' });
        }

        // Locate the item whose product ID matches the provided product ID
        const item = cart.items.find(item => item.product && item.product._id.toString() === productId);

        if (item) {
            item.quantity += 1;
            await cart.save();
            res.status(200).json({ status: 'success', message: 'Quantity incremented', cart });
        } else {
            console.log(`Product with ID ${productId} not found in cart`);
            res.status(404).json({ status: 'error', message: 'Product not found in cart' });
        }
    } catch (error) {
        console.error('Error incrementing product quantity:', error);
        res.status(500).json({ status: 'error', message: `Error updating cart: ${error.message}` });
    }
}



// Decrement product quantity in the cart
// Decrement product quantity in the cart
export async function decrementProductQuantity(req, res) {
    const userId = req.user?.userId;
    const { productId } = req.body;

    if (!userId) {
        return res.status(403).json({ status: 'error', message: 'Access denied. No user associated with this token.' });
    }

    try {
        const cart = await Cart.findOne({ user: userId }).populate('items.product');
        if (!cart) {
            return res.status(404).json({ status: 'error', message: 'Cart not found.' });
        }

        // Find index using robust checking for null product references
        const itemIndex = cart.items.findIndex(item => item.product && item.product._id.toString() === productId);

        if (itemIndex !== -1) {
            const item = cart.items[itemIndex];
            if (item.quantity > 1) {
                item.quantity -= 1;
            } else {
                // Remove the item if quantity is 1 or less
                cart.items.splice(itemIndex, 1);
            }
            await cart.save();
            res.status(200).json({
                status: 'success',
                message: 'Quantity updated',
                cart
            });
        } else {
            res.status(404).json({ status: 'error', message: 'Product not found in cart' });
        }
    } catch (error) {
        console.error('Error decrementing product quantity:', error);
        res.status(500).json({ status: 'error', message: `Error updating cart: ${error.message}` });
    }
};



export async function deleteProductFromCart(req, res) {
    const userId = req.user?.userId;  // Assuming 'userId' is extracted from the token
    const { productId } = req.body;

    if (!userId) {
        return res.status(403).json({ status: 'error', message: 'Access denied. No user associated with this token.' });
    }

    try {
        const cart = await Cart.findOne({ user: userId });
        if (!cart) {
            return res.status(404).json({ status: 'error', message: 'Cart not found.' });
        }

        // Check if product exists in the cart
        const itemIndex = cart.items.findIndex(item => item.product.toString() === productId);
        if (itemIndex !== -1) {
            cart.items.splice(itemIndex, 1);  // Remove the item from the cart
            await cart.save();
            return res.status(200).json({ status: 'success', message: 'Product removed from cart', cart });
        } else {
            return res.status(404).json({ status: 'error', message: 'Product not found in cart' });
        }
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Error removing product from cart: ${error.message}` });
    }
}


export async function getCartCount (req, res) {
    const userId = req.user?.userId;  // Extract user ID from token
    if (!userId) {
      return res.status(403).json({ status: 'error', message: 'Unauthorized' });
    }
  
    try {
      const cart = await Cart.findOne({ user: userId });
      const itemCount = cart ? cart.items.reduce((sum, item) => sum + item.quantity, 0) : 0;
      res.status(200).json({ status: 'success', count: itemCount });
    } catch (error) {
      res.status(500).json({ status: 'error', message: 'Error fetching cart count' });
    }
  }
  