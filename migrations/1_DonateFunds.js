const DonateFunds = artifacts.require("DonateFunds");

module.exports = function (deployer) {
  deployer.deploy(DonateFunds);
};
