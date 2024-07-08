import connectDb from '../db/db.js';
import {registerUser,LoginUser} from '../controllers/registerUser.js';
import { resetPassword,requestPasswordReset } from '../controllers/userController.js';
const initApp = (app,express)=>{
    app.use(express.jason());
    connectDb();
    //Routes
    app.use('/register', registerUser);
    app.use('/Login', LoginUser);
    app.use('/forgotpassword', requestPasswordReset);
    app.use('/resetpassword', resetPassword);
};



export default initApp;