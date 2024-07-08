import User from '../models/userModel.js'; 
export const getProfile = async (req, res) => {
    try {
          if (!req.user) {
           return res.status(401).json({ error: 'User not authenticated' });
           }
           
          const userId = req.user; 
    
        
          const user = await User.findOne({
            where: { User_id: userId },
          });
      
          const userProfile = {
            UserPicture: user.UserPicture,
            Username: user.Username,
            UserType: user.UserType,
            PhoneNumber: user.PhoneNumber,
            Email: user.Email,
            
          };
      
          if (user.UserType === 'store') {
            userProfile.UserProfileInfo= user.UserProfileInfo;
            userProfile.Rating = user.Rating;

          }
    
          res.status(200).json(userProfile);
      } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed to fetch user profile' });
      }
  };
  export const getProfilefromID = async (req, res) => {
    try {
  
          const {userId}= req.params; 
    
          const user = await User.findOne({
            where: { User_id: userId },
          });
      
          const userProfile = {
            UserPicture: user.UserPicture,
            Username: user.Username,
            // UserType: user.UserType,
            // PhoneNumber: user.PhoneNumber,
            // Email: user.Email,
          };
      
          if (user.UserType === 'store') {
            
            userProfile.PhoneNumber = user.PhoneNumber;
            // userProfile.Email = user.Rating;
            userProfile.UserProfileInfo= user.UserProfileInfo;
            userProfile.Rating = user.Rating;
          }
    
          res.status(200).json(userProfile);
      } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed to fetch user profile' });
      }
  };  

  export const editProfile = async (req, res) => {
    try {
      if (!req.user) {
        return res.status(401).json({ error: 'User not authenticated' });
      }
  
      const userId = req.user;
  
      const user = await User.findByPk(userId);
  
      const { UserPhoneNumber, Email, Useraddress} = req.body;

      if ( Email !== user.Email ) {
        const emailExist = await User.findOne({ where: { Email } });
        if (emailExist) {
          return res.status(400).json('Email already exists');
        }
      }
      user.Address = Useraddress|| user.Address;
      user.PhoneNumber = UserPhoneNumber || user.UserPhoneNumber;
      user.Email = Email || user.Email;
    //   user.UserProfileInfo = UserProfileInfo || user.UserProfileInfo;

      if (user.UserType === 'store') {
        const { UserProfileInfo} = req.body;
        user.UserProfileInfo = UserProfileInfo || user.UserProfileInfo;
    //   const { Price } = req.body;
    //   user.Price = Price || user.Price;
      }

      await user.save();
  
      res.status(200).json('تم تغيير معلومات الحساب بنجاح');
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Failed to update user profile' });
    }
  };

  export const editProfileImage = async (req, res) => {
    try {
      if (!req.user) {
        return res.status(401).json({ error: 'User not authenticated' });
      }
  
      const userId = req.user; 
  
      const user = await User.findByPk(userId);
  
      const {userImage } = req.body;
      
      user.UserPicture = userImage || user.UserPicture;
  
      await user.save();
  
      res.status(200).json('تم تحديث الصورة الشخصية');
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Failed to update user Image' });
    }
  };