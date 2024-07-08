import Notification from '../models/NotificationModel.js';

/**
 * Fetches notifications for the specified store.
 * @param {Object} req HTTP request object.
 * @param {Object} res HTTP response object.
 */



export async function getNotifications_S(req, res) {
    try {
        // تحقق من وجود معرف المتجر في الطلب
        const storeId = req.params.storeId;
        // if (!storeId) {
        //     return res.status(403).json({ status: 'error', message: 'Store ID is required.' });
        // }

        // استرجاع الإشعارات للمتجر المحدد فقط
        const notifications = await Notification.find({ receiverId: storeId });
        if (notifications.length === 0) {
            return res.status(404).json({ status: 'error', message: 'No notifications found.' });
        }
        
        res.status(200).json({
            status: 'success',
            message: 'Notifications found.',
            notifications
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: `Failed to get notifications: ${error.message}` });
    }
}



export async function getNotifications(req, res) {
  try {
    // تحقق من وجود معرف المستخدم في الطلب
    const userId = req.user?.userId;
    if (!userId) {
        return res.status(403).json({ status: 'error', message: 'User ID is required.' });
    }

    // استرجاع الإشعارات للمستخدم الحالي فقط
    const notifications = await Notification.find({ receiverId: userId });
    if (notifications.length === 0) {
        return res.status(404).json({ status: 'error', message: 'No notifications found.' });
    }
    
    res.status(200).json({
        status: 'success',
        message: 'Notifications found.',
        notifications
    });
  } catch (error) {
      res.status(500).json({ status: 'error', message: `Failed to get notifications: ${error.message}` });
  }
}




export const getNotification_SCount = async (req, res) => {
  try {
      const userId = req.user?.userId; // استخراج معرف المستخدم من التوكن
      
      if (!userId) {
          return res.status(403).json({ status: 'error', message: 'User ID is required.' });
      }

      const notificationCount = await Notification.countDocuments({
          receiverId: userId,
          isRead: false
      });

      res.status(200).json({ status: 'success', count: notificationCount });
  } catch (error) {
      console.error(error);
      res.status(500).json({ status: 'error', message: 'Error getting notification count' });
  }
};
  
export const getNotificationCount = async (req, res) => {
    try {
        const userId = req.user?.userId; // استخراج معرف المستخدم من التوكن
        
        if (!userId) {
            return res.status(403).json({ status: 'error', message: 'User ID is required.' });
        }
  
        const notificationCount = await Notification.countDocuments({
            receiverId: userId,
            isRead: false
        });
  
        res.status(200).json({ status: 'success', count: notificationCount });
    } catch (error) {
        console.error(error);
        res.status(500).json({ status: 'error', message: 'Error getting notification count' });
    }
  };
    
  

export const markAllNotificationsAsRead = async (req, res) => {
    try {
        const userId = req.user?.userId; // استخراج معرف المستخدم من التوكن

        if (!userId) {
            return res.status(403).json({ status: 'error', message: 'User ID is required.' });
        }

        const result = await Notification.updateMany(
            { receiverId: userId, isRead: false },
            { $set: { isRead: true } }
        );

        res.status(200).json({ status: 'success', message: 'All notifications marked as read', modifiedCount: result.nModified });
    } catch (error) {
        console.error(error);
        res.status(500).json({ status: 'error', message: 'Error updating notifications' });
    }
};

