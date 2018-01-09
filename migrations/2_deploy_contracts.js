const MoneiToken = artifacts.require('./MoneiToken.sol');

module.exports = function(deployer, network, accounts) {
  const initialSupply = 50000;
  const tokenName = 'MONEI UNI';
  const tokenSymbol = 'UNI';
  const tokenSellPrice = 1;
  const tokenBuyPrice = 1;
  const minBalance = 672197500000021000;
  deployer.deploy(
    MoneiToken,
    initialSupply,
    tokenName,
    tokenSymbol,
    tokenSellPrice,
    tokenBuyPrice,
    minBalance
  );
};
