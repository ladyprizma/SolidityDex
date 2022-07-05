pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Dex {

    event Bought(uint256 amount);
    event Sold(uint256 amount);
    address owner;
    mapping(IERC20 => uint) public liquidty;
    uint256 public tradingVault = 0;

    using SafeMath for uint256;



    constructor() {
        owner = msg.sender;
    }

    function buy(IERC20 token) payable public {
        uint256 amountTobuy = msg.value;
        require(amountTobuy > 0, "You need to send some ether");
        liquidty[token] = liquidty[token].add(amountTobuy-((amountTobuy*25)/10000));
        tradingVault = tradingVault.add((amountTobuy*25)/10000);
        uint256 dividedbalance = token.balanceOf(address(this)).div(100000000);
        token.transfer(msg.sender, ((amountTobuy/(liquidty[token]/dividedbalance))*100000000));
        emit Bought(amountTobuy);
    }

    function sell(IERC20 token, uint256 amount) payable public {
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), amount);
        uint256 dividedamount = amount.div(100000000);
        uint256 dividedbalance = token.balanceOf(address(this)).div(100000000);
        uint256 transferamount = ((liquidty[token]/(dividedbalance+dividedamount))*dividedamount);
        payable(msg.sender).transfer(transferamount-((transferamount*25)/10000));
        tradingVault = tradingVault.add((transferamount*25)/10000);
        liquidty[token] = liquidty[token].sub((liquidty[token]/(dividedbalance+dividedamount))*dividedamount);
    }

    function addLiquidty(IERC20 token, uint256 amount) payable public {
        uint256 amountTobuy = msg.value;
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), amount);
        liquidty[token] = liquidty[token].add(amountTobuy);
    }

    function getPrice(IERC20 token) public view returns (uint256) {
        uint256 dividedbalance = token.balanceOf(address(this)).div(100000000);
        return (liquidty[token]/dividedbalance);
    }

    function fetchVault() public payable{
        require(msg.sender == owner, "Not Authenticated!");
        payable(msg.sender).transfer(tradingVault);
        tradingVault = 0;
    }

}
library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
}