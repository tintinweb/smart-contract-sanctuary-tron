//SourceUnit: 20filler.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface TRC20 {
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TFiller {
    using SafeMath for uint256; 
    
    TRC20 public usdt;
   
    address payable owner;
   
    event Deposit(address user, uint256 amount);
    event AirDrop(address user, uint256 amount);
   
    modifier onlyOwner(){
        require(msg.sender == owner,"You are not owner.");
        _;
    }
    
    constructor(address _usdt) public {
        usdt = TRC20(_usdt);
        owner = msg.sender;
        
    }
    
    function contractInfo() public view returns(uint256 balance){
       return (usdt.balanceOf(address(this)));
    }
    
    function deposit(uint256 _amount) external {
        usdt.transferFrom(msg.sender, address(this), _amount);
        emit Deposit(msg.sender, _amount);
    }
    
    function airdrop(address _buyer, uint256 _amount) public onlyOwner{
        usdt.transfer(_buyer, _amount);
        emit AirDrop(_buyer,_amount);
    }
 
}

library SafeMath {
   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}