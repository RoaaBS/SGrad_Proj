// Import HTTPS function trigger
const { onRequest } = require("firebase-functions/v2/https");
// Import logger from Firebase Functions
const logger = require("firebase-functions/logger");

/**
 * An HTTP-triggered Cloud Function that responds with "Hello from Firebase!"
 * This function logs a message before sending the response.
 */
exports.helloWorld = onRequest((request, response) => {
  // Log a message
  logger.info("Hello logs!", { structuredData: true });
  
  // Send response to the request
  response.send("Hello from Firebase!");
});
