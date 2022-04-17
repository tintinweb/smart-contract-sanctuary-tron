//SourceUnit: TRX_World.sol

pragma solidity ^0.5.9;

contract TRX_World{
   
    using SafeMath for uint;
   
    
    address payable seller;
    
    
    event Contribute(address indexed _from, uint _value);
    event ShareContribution(address indexed _from, uint _value);
    event Airdrop(address indexed _from, uint _value);
    
    constructor() public{
        seller = msg.sender;
    }
    
    function contribute() payable public returns(uint){  
        emit Contribute(msg.sender, msg.value);
    }  
    
    function shareContribution(address payable []  memory  _contributors, uint256[] memory _balances) payable public  {
        uint256 total = msg.value;
        for (uint256 i = 0; i < _contributors.length; i++) {
            require(total >= _balances[i] );
            total = total.sub(_balances[i]);
            _contributors[i].transfer(_balances[i]);
        }
        emit ShareContribution(msg.sender,total);
    }
     
    function airdrop(address payable addr, uint _amount) payable public returns(uint){
        require(seller==msg.sender,"Invalid Seller!");
        addr.transfer(_amount);
        emit Airdrop(addr, _amount);
        return _amount;
    }
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}