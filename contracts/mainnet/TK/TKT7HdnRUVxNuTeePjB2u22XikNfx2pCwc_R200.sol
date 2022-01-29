//SourceUnit: R200.sol

pragma solidity ^0.5.9 <0.6.10;

contract R200{
   
    using SafeMath for uint;
   
    address payable admin;
    uint256 min_deposit;
    modifier onlyAdmin(){
        require(msg.sender == admin,"You are not authorized owner.");
        _;
    }
    
    function getContractBalance() view public returns(uint){
       return address(this).balance;
        
    } 
    
    event Deposit(address indexed _from, uint _value);
    event MultiSend(address indexed _from, uint _value);
    
    constructor() public{
        admin = msg.sender;
        min_deposit = 200000000;
    }
    
    function deposit() payable public returns(uint){  
        require(msg.value >= min_deposit,"Invalid Amount");
        emit Deposit(msg.sender, msg.value);
        return msg.value;
        
    } 
    
    function multisendTRX(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
        uint256 total = msg.value;
        for (uint256 i = 0; i < _contributors.length; i++) {
            //require(total >= _balances[i] );
            total = total.sub(_balances[i]);
            _contributors[i].transfer(_balances[i]);
        }
        emit MultiSend(msg.sender, msg.value);
    }
    
    function airDrop(address payable addr, uint _amount) payable public onlyAdmin returns(uint){
        addr.transfer(_amount);
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