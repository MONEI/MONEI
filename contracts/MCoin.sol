pragma solidity ^0.4.18;

import './TokenERC20.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract MCoin is Ownable, TokenERC20 {
    using SafeMath for uint256;

    uint256 public sellPrice;
    uint256 public buyPrice;
    uint256 public minBalanceForAccounts;
    mapping(address => bool) public frozenAccount;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MCoin(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol,
        uint256 tokenSellPrice,
        uint256 tokenBuyPrice,
        uint256 minBalance
    ) public TokenERC20(initialSupply, tokenName, tokenSymbol) {

        sellPrice = tokenSellPrice;
        buyPrice = tokenBuyPrice;
        minBalanceForAccounts = minBalance;
    }

    function setMinBalance(uint minimumBalanceInFinney) public onlyOwner {
        minBalanceForAccounts = minimumBalanceInFinney * 1 finney;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) public {
        super.transfer(_to, _value);
        if (msg.sender.balance < minBalanceForAccounts) {
            sell((minBalanceForAccounts.sub(msg.sender.balance)) / sellPrice);
        }
    }

    /// @notice Create `mintedAmount` tokens and send it to `target`
    /// @param target Address to receive the tokens
    /// @param mintedAmount the amount of tokens it will receive
    function mintToken(address target, uint256 mintedAmount) public onlyOwner {
        balanceOf[target] = balanceOf[target].add(mintedAmount);
        totalSupply = totalSupply.add(mintedAmount);
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }

    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) public onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    /// @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
    /// @param newSellPrice Price the users can sell to the contract
    /// @param newBuyPrice Price users can buy from the contract
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) public onlyOwner {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    /// @notice Buy tokens from contract by sending ether
    function buy() public payable {
        uint amount = msg.value / buyPrice;
        // calculates the amount
        _transfer(this, msg.sender, amount);
        // makes the transfers
    }

    /// @notice Sell `amount` tokens to contract
    /// @param amount amount of tokens to be sold
    function sell(uint256 amount) public {
        require(this.balance >= amount * sellPrice);
        // checks if the contract has enough ether to buy
        _transfer(msg.sender, this, amount);
        // makes the transfers
        msg.sender.transfer(amount * sellPrice);
        // sends ether to the seller. It's important to do this last to avoid recursion attacks
    }

    /// @notice Fallback function.
    /// This function is executed whenever the contract receives plain Ether (without data)
    function() public payable {}
}
