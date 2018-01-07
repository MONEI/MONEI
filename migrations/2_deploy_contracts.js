var MCoin = artifacts.require('./MCoin.sol');

module.exports = function(deployer, network, accounts) {
  const initialSupply = 50000;
  const tokenName = 'MONEI UNI';
  const tokenSymbol = 'UNI';
  const tokenSellPrice = 1;
  const tokenBuyPrice = 1;
  const minBalance = web3.toWei(5, 'finney');
  deployer.deploy(MCoin, initialSupply, tokenName, tokenSymbol, tokenSellPrice, tokenBuyPrice, minBalance);
};
