import jwt from 'jsonwebtoken';
import 'dotenv/config';  // Ensure this is loaded to access process.env variables

/**
 * Middleware to verify the JWT token and attach either user or store data to the request object.
 * @param {Object} req - The request object.
 * @param {Object} res - The response object.
 * @param {Function} next - The next middleware function.
 */
function verifyToken(req, res, next) {
    const token = req.headers.authorization;

    if (!token) {
        return res.status(401).json({ message: "No token provided." });
    }

    jwt.verify(token, process.env.JWT_SECRET_KEY, (err, decoded) => {
        if (err) {
            return res.status(401).json({ message: "Invalid token." });
        }

        // Check the decoded token for user or store identification
        if (decoded.userId) {
            req.user = decoded;
        } else if (decoded.storeId) {
            req.store = decoded;  // Attach store-specific information if token has storeId
        } else {
            return res.status(401).json({ message: "Token does not contain appropriate identification." });
        }
        
        next();  // Proceed to the next middleware or the route handler
    });
}

export { verifyToken };
