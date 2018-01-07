// Specifically request an abstraction for MetaCoin
const MCoin = artifacts.require('MCoin');

let instance;

beforeEach(async () => {
  instance = await MCoin.deployed();
  return instance;
});

contract('MCoin', accounts => {
  it('should put 50000 UNI in the first account', async () => {
    const balance = await instance.balanceOf(accounts[0]);
    assert.equal(balance.valueOf(), 50000 * Math.pow(10, 18));
  });

  it.only('should refund ether fee when transferring UNI', async () => {
    // keep only 1 ether on account 1
    const balance = web3.eth.getBalance(accounts[1]).valueOf();
    const limit = 672197500000021000;
    await web3.eth.sendTransaction({
      from: accounts[1],
      to: accounts[0],
      value: balance - limit
    });

    // save balance of account 1
    const initialBalance = web3.eth.getBalance(accounts[1]);

    // send 50 ether to the contract
    await instance.send(web3.toWei(50, 'ether'));

    // transfer 10 UNI to account 1
    await instance.transfer(accounts[1], web3.toWei(10, 'ether'));

    // check if account 1 receives 10 UNI
    const uni = await instance.balanceOf(accounts[1]);
    assert.equal(uni.valueOf(), 10 * Math.pow(10, 18));

    // send 5 UNI from account 1 to account 2
    await instance.transfer(accounts[2], web3.toWei(5, 'ether'), {from: accounts[1]});

    const finalBalance = web3.eth.getBalance(accounts[1]);

    assert.equal(initialBalance.valueOf(), finalBalance.valueOf());
  });
});
