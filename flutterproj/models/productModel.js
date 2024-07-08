import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

const Product = sequelize.define('Product', {
  ProductId: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    allowNull: false
  },
  User_id: {
    type: DataTypes.INTEGER,
    allowNull: true,
  },
  CategoryName: {
    type: DataTypes.STRING,
    allowNull: false
  },
  ProductName: {
    type: DataTypes.STRING,
    allowNull: false
  },
  ProductPrice: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  Quantity: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  Image: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  CreatedAt: {
    type: DataTypes.DATE,
    allowNull: true
  },
  Description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  Discount: {
    type: DataTypes.FLOAT,
    allowNull: false,
    defaultValue: 0 // Assuming no discount by default
  },
}, {
    timestamps: false 
});

Product.sync()
  .then(() => console.log('Product model synchronized with the database'))
  .catch((err) => console.error('Product model synchronization failed:', err));

export default Product;
