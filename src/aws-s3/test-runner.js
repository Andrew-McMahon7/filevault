const Mocha = require('mocha');
const path = require('path');

// Instantiate a Mocha instance.
const mocha = new Mocha();

// Add the test file to the Mocha instance
mocha.addFile(path.join(__dirname, 'test/index.test.js'));

// Run the tests.
mocha.run((failures) => {
    process.exitCode = failures ? 1 : 0; // exit with non-zero status if there were failures
});