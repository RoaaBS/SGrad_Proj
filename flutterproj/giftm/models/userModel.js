import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
    // userId: { type: Number, required: true },
    username: { type: String, required: true },
    userType: { type: String, enum: ['ادمن','مستخدم', 'صاحب متجر'], required: true },
    email: { type: String, required: true },
    password: { type: String, required: true },
    phoneNumber: { type: String, default: null},
    address: { type: String, default: null },
    userProfileInfo: { type: String, default: null },
    userPicture: { type: String, default: null },
    rating: { type: Number, default: null },
    verified: { type: Boolean, default: false }, // تعديل الحقل الموجود للتأكيد على البريد الإلكتروني
    licenseImage: { type: String, default: null },
    verificationCode: { type: Number, default: null }, // إضافة حقل رمز التحقق
    resetPasswordToken: { type: String, default: null },
    resetPasswordExpires: { type: Date, default: null }
});

const User = mongoose.model('User', userSchema);

export default User;