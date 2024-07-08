import mongoose from 'mongoose';

const NotificationSchema = new mongoose.Schema({
    senderName: {
        type: String,
        required: true
    },
    content: {
        type: String,
        required: true
    },
    senderId: {
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'Store',
        required: true
    },
    receiverId: {
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'User',
        required: true
    },
    isRead: {
        type: Boolean,
        required: true,
        default: false
    },
    senderPicture: {
        type: String,
        required: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    },
    type: {
        type: String,
        required: true
    }
});

const Notification = mongoose.model('Notification', NotificationSchema);

export default Notification;
