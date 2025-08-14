const { jestConfig } = require("@salesforce/sfdx-lwc-jest/config");

module.exports = {
  ...jestConfig,
  modulePathIgnorePatterns: ["<rootDir>/.localdevserver", "<rootDir>/.history"],
  reporters: [
    "default",
    [
      "jest-junit",
      {
        outputDirectory: "./test-results",
        outputName: "test-results.xml",
        suiteName: "LWC Jest Tests"
      }
    ]
  ],
  collectCoverageFrom: [
    "force-app/main/default/lwc/**/*.js",
    "!force-app/main/default/lwc/**/__tests__/**"
  ],
  coverageDirectory: "./coverage",
  coverageReporters: ["text", "lcov", "html"]
};
