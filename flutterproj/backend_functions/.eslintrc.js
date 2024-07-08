// .eslintrc.js
module.exports = {
  env: {
      node: true, // Ensures Node.js global variables and Node.js scoping.
      es2021: true
  },
  extends: [
      "eslint:recommended"
  ],
  parserOptions: {
      ecmaVersion: 12, // Supports newer ECMAScript features
      sourceType: "script" // Uses CommonJS
  },
  rules: {
      "no-restricted-globals": ["error", "name", "length"],
      "prefer-arrow-callback": "error",
      "quotes": ["error", "double", {"allowTemplateLiterals": true}]
  }
};
a