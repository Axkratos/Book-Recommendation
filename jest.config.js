// jest.config.js
export default {
  testEnvironment: 'node',
  transform: {},
    testMatch: [
        '**/tests/**/*.test.js'
    ],
  moduleNameMapper: {
    '^(\\.{1,2}/.*)\\.js$': '$1'
  }
};
