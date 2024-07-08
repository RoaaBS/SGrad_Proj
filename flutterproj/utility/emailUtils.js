// emailUtils.js
import nodemailer from 'nodemailer';


const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'doaawaqas16.2001@gmail.com',
    pass: 'jquq cwny fmpc tjah',
  },
});

export const sendResetPasswordEmail = async (email, resetCode) => {
  const mailOptions = {
    from: 'doaawaqas16.2001@gmail.com', // Your email address
    to: email,
    subject: 'اعادة تعيين كلمة السر',
    html: `<h1>هل تريد اعادة تعيين كلمة السر</h1> 
    <h2>${resetCode}</h2>
    <p>
    You have requested a password reset. 
    use the confirmation code below to complete the process. If you didn't make this request, ignore this email.
    <p>${resetCode}</p>
    </p>`,
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log('Email sent: ' + info.response);
  } catch (error) {
    console.error('Email not sent: ' + error);
  }
};
export const generateUniqueCode = (length = 4) => {
  let code = '';
  const characters = '0123456789'; // Use only digits for an OTP
  for (let i = 0; i < length; i++) {
    code += characters.charAt(Math.floor(Math.random() * characters.length));
  }
  return code;
};

