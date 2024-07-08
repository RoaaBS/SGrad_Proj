import Product from '../models/productModel.js'; 

export const addProduct = async (req, res) => {
  try {
    
    if (!req.user) {
        return res.status(401).json({ error: 'User not authenticated' });
      }
  
      const userId = req.user;

    const { CategoryName, ProductName, ProductPrice, Quantity, Image, Description } = req.body;

    // Validate the necessary fields are provided
    if (!CategoryName || !ProductName || !ProductPrice || !Quantity) {
      return res.status(400).json('ادخل جميع الخانات اللازمة');
    }

    // Create a new product in the database
    const newProduct = await Product.create({
      User_id:userId, // Ensure User_id is an integer
      CategoryName,
      ProductName,
      ProductPrice,
      Quantity,
      Image: Image !== "" ? Image : 'path/to/default/image.png', // Provide a default image path if none is provided
      CreatedAt: new Date(),
      Description: Description !== "" ? Description : ProductName
    });

    // Respond with the newly created product
    res.status(201).json({
      productId: newProduct.ProductId,
      productName: newProduct.ProductName,
      message: 'Product successfully added'
    });
  } catch (error) {
    console.error('Error adding product:', error);

    if (error.name === 'SequelizeValidationError') {
      return res.status(400).json({ error: 'Validation error. Please provide valid data' });
    }

    res.status(500).json({ error: 'Failed to add product' });
  }
};

export const deleteProduct = async (req, res) => {
    try {
        if (!req.user) {
            return res.status(401).json({ error: 'User not authenticated' });
          }
      
      const { ProductId } = req.params; 
  
      // First, check if the product exists
      const product = await Product.findByPk(ProductId);
      if (!product) {
        return res.status(404).json('Product not found');
      }
  
      // Delete the product
      await Product.destroy({
        where: { ProductId }
      });
  
      // Respond to the client
      res.status(200).json({ message: 'Product successfully deleted' });
    } catch (error) {
      console.error('Error deleting product:', error);
      if (error.name === 'SequelizeValidationError') {
        return res.status(400).json({ error: 'Validation error. Please provide valid data' });
      }
      res.status(500).json({ error: 'Failed to delete product' });
    }
  };
  
  export const updateProduct = async (req, res) => {
    try {
      if (!req.user) {
        return res.status(401).json({ error: 'User not authenticated' });
      }
  
      const { ProductId } = req.params; // Ensure this is correctly captured from the URL
  
      // Find the product by its ID
      const product = await Product.findByPk(ProductId);
      if (!product) {
        return res.status(404).json({ message: 'Product not found' });
      }
  
      const { CategoryName, ProductName, ProductPrice, Quantity, Image, Description } = req.body;
  
      // Update the product with new values; Sequelize's `update` method can be used here
      const updatedProduct = await product.update({
        CategoryName,
        ProductName,
        ProductPrice,
        Quantity,
        Image: Image || product.Image, // Fallback to existing value if not provided
        Description: Description || product.Description // Fallback to existing value if not provided
      });
  
      res.status(200).json({
        message: 'Product successfully updated',
        product: updatedProduct
      });
    } catch (error) {
      console.error('Error updating product:', error);
      res.status(500).json({ error: 'Failed to update product' });
    }
  };
  