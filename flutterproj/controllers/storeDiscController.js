import Product from '../models/productModel.js'; 

export const addDiscountToProduct = async (req, res) => {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'User not authenticated' });
    }

    const { ProductId } = req.params;
    const { discount } = req.body; // Discount percentage

    // Validate discount value
    if (discount < 0 || discount > 100) {
      return res.status(400).json({ error: 'Invalid discount value' });
    }

    const product = await Product.findByPk(ProductId);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    await product.update({
      Discount: discount
    });

    res.status(200).json({
      message: 'Discount added successfully',
      product: {
        ProductId: product.ProductId,
        Discount: product.Discount
        
      }
    });
  } catch (error) {
    console.error('Error adding discount:', error);
    res.status(500).json({ error: 'Failed to add discount to product' });
  }
};

export const addDiscountToAllProducts = async (req, res) => {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'User not authenticated' });
    }

    const { discount } = req.body; // Discount percentage

    // Validate discount value
    if (discount < 0 || discount > 100) {
      return res.status(400).json({ error: 'Invalid discount value' });
    }

    // Assuming req.user is the store's User_id
    const userId = req.user;

    const updated = await Product.update({
      Discount: discount
    }, {
      where: { User_id: userId }
    });

    res.status(200).json({
      message: `Discount of ${discount}% added to all products successfully`,
      updatedRows: updated[0] // Number of rows updated
    });
  } catch (error) {
    console.error('Error adding discount to all products:', error);
    res.status(500).json({ error: 'Failed to add discount to all products' });
  }
};
