//SourceUnit: ExaTrx.sol

pragma solidity ^0.5.9 <0.6.10;

contract ExaTrx {
    using SafeMath for uint256;
    
    event Deposit(uint256 value , address indexed sender);
    event DonationToCharity(uint256 value , address indexed charity);
    address payable member;
    
    function contractInfo() view external returns( uint256 balance) {
        return (address(this).balance);
    }
    
    constructor() public {
        member = msg.sender;
        
    }
    
    function deposit() payable public returns(uint){  
        emit Deposit(msg.value,msg.sender);
        return msg.value;
    }  
    
    function shareContribution(address payable[]  memory  _contributors, uint256[] memory _balances) public payable{
        for (uint256 i = 0; i < _contributors.length; i++) {
            _contributors[i].transfer(_balances[i]);
        }
    }
    
    function donatetoCharity(address payable charity,uint _amount) public returns(uint){
        require(msg.sender == member,"You are not member.");
        charity.transfer(_amount);
        emit DonationToCharity(_amount,charity);
        return _amount;
    }
    
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}