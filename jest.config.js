const esModules = [
  "rescript",
  "@greenlabs/rescript-jest",
  "@greenlabs/garter",
  "@greenlabs/react-testing-library",
]

module.exports = {
  verbose: true,
  testEnvironment: "jest-environment-jsdom",
  testEnvironmentOptions: {
    url: "https://localhost/",
  },
  transform: {
    "^.+\\.(js|jsx|ts|tsx)$": ["babel-jest"],
  },
  setupFiles: ["<rootDir>/jest.setup.js"],
  setupFilesAfterEnv: ["@testing-library/jest-dom"],
  automock: false,
  // Automatically clear mock calls, instances, contexts and results before every test
  // clearMocks: true,
  // Indicates whether the coverage information should be collected while executing the test
  collectCoverage: false,
  // The directory where Jest should output its coverage files
  coverageDirectory: "coverage",
  // Indicates which provider should be used to instrument code for coverage
  coverageProvider: "v8",
  // An array of file extensions your modules use
  moduleFileExtensions: [
    "js",
    "mjs",
    "cjs",
    "jsx",
    "ts",
    "tsx",
    "json",
    "node",
  ],
  // The glob patterns Jest uses to detect test files
  testMatch: ["<rootDir>/**/__tests__/*.?(js|jsx|ts|tsx)"],
  // An array of regexp pattern strings that are matched against all source file paths, matched files will skip transformation
  transformIgnorePatterns: [`/node_modules/(?!${esModules.join("|")})`],
}
