import { DataTypes } from 'sequelize';
import sequelize from '../db.js';

const User = sequelize.define('User', {
  User_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    // autoIncrement: true
  },
  Username: { 
    type: DataTypes.STRING
  },
  Email: {
    type: DataTypes.STRING,
    unique: true,
  },
  Password: {
    type: DataTypes.STRING
  },
  PhoneNumber: {
    type: DataTypes.STRING
  },
  Address: {
    type: DataTypes.STRING
  },
  UserType: {
    type: DataTypes.STRING
  },
  UserProfileInfo: {
    type: DataTypes.TEXT,
  },
  UserPicture: {
    type: DataTypes.TEXT,
  },
  Rating: {
    type: DataTypes.FLOAT

  },
  
}, {
  timestamps: false 
});


User.sync()
  .then(() => console.log('User model synchronized with the database'))
  .catch((err) => console.error('User model synchronization failed:', err));

export default User;