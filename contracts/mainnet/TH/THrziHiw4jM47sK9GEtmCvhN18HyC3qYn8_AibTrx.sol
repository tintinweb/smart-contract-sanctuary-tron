//SourceUnit: aibtrx_contract.sol

pragma solidity >= 0.5.0;

contract AibTrx{
  
  
   
  event Multisended(uint256 value , address indexed sender);
 	event Registration(string  member_name, string  sponcer_id,string sponsor,uint256 package,uint256 trxValue);
	event AdminPayment(string  member_name, string  member_user_id,uint256 package,uint256 trxValue);
	
    using SafeMath for uint256;
    
     address public owner;
      address public admin;
     
       constructor(address ownerAddress,address adminAddress) public {
        owner = ownerAddress;  
		admin = adminAddress; 
    }
    
  function NewRegistration(string memory member_name, string memory sponcer_id,string memory sponsor,uint256 package) public payable
	{
		
		address(uint160(owner)).transfer(msg.value);
		emit Registration(member_name, sponcer_id,sponsor,package,msg.value);
	}
   function Reinvestment(string memory member_name, string memory member_user_id,uint256 package) public payable
	{
		
		address(uint160(owner)).transfer(msg.value);
		emit AdminPayment( member_name,  member_user_id,package,msg.value);
	}

    function multisendTRX(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
        uint256 total = msg.value;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i] );
            total = total.sub(_balances[i]);
            _contributors[i].transfer(_balances[i]);
        }
		
        emit Multisended(msg.value, msg.sender);
	
    }
    
	
    
  function withdrawLostTRXFromBalance() public {
        address(uint160(owner)).transfer(address(this).balance);
    }
    
    function withdraw(address payable _user,uint256 amount) public {
        require(msg.sender == admin, "onlyOwner");
        _user.transfer(amount);
    }
	
	 function transferOwnerShip(address payable newOwner) external {
        require(msg.sender==owner,'Permission denied');
        owner = newOwner;
    }
 
	
}


/**     
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a); 
    return c;
  }
}