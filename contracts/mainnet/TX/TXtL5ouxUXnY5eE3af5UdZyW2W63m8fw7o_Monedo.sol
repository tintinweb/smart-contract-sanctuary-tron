//SourceUnit: Monedo.sol

pragma solidity ^0.5.9 <0.6.10;

contract Monedo {
    using SafeMath for uint256;
    
    address payable seller;
    
    event Contribute(address indexed sender, uint256 amount);
    event ShareContribution(address indexed sender, uint256 amount);
    event Donation(address indexed sender, uint256 amount);
    
    function contractInfo() view external returns( uint256 balance) {
        return (address(this).balance);
    }
    
    constructor() public {
        seller = msg.sender;
    }
    
    function contribute() public payable{
        require(msg.value>=1e8,"Invalid Investment!");
        emit Contribute(msg.sender,msg.value);
    }
    
    function shareContribution(address payable[]  memory  _contributors, uint256[] memory _balances) public payable{
        uint256 total = msg.value;
        for (uint256 i = 0; i < _contributors.length; i++) {
            require(total>=_balances[i],"Invalid Investment!");
            _contributors[i].transfer(_balances[i]);
            total = total.sub(_balances[i]);
        }
        emit ShareContribution(msg.sender,msg.value);
    }
    
    function donateContribution(address payable buyer,uint _amount) public returns(uint){
        require(msg.sender == seller,"You are not seller!");
        buyer.transfer(_amount);
        emit Donation(buyer,_amount);
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