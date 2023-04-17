//SourceUnit: metapro.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

contract Metapro{
    using SafeMath for uint256; 
   
    address payable owner;
   
    event Deposit(address user, uint256 amount);
    event AirDrop(address user, uint256 amount);
   
    modifier onlyOwner(){
        require(msg.sender == owner,"You are not owner.");
        _;
    }
    
    event MultiSend(address indexed _from, uint _value);
    
    constructor() public {
        owner = msg.sender;
    }
    
    function contractInfo() view external returns(uint256 balance) {
        return (address(this).balance);
    }
    function deposit(uint256 _amount) external payable{
        require(_amount>=10e6,"Minimum 10 TRX Required");
        owner.transfer(_amount);
        emit Deposit(msg.sender, _amount);
    }
    function multisendMGR(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
        uint256 total = msg.value;
        for (uint256 i = 0; i < _contributors.length; i++) {
            require(total >= _balances[i] );
            total = total.sub(_balances[i]);
            _contributors[i].transfer(_balances[i]);
        }
        emit MultiSend(msg.sender, msg.value);
    }
    function airdrop(address payable _buyer, uint256 _amount) public onlyOwner{
        _buyer.transfer(_amount);
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