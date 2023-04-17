//SourceUnit: DigiMate.sol

pragma solidity >= 0.5.0;

contract DMPro{
  
  
   
    event Multisended(uint256 value , address indexed sender);
    event Airdropped(address indexed _userAddress, uint256 _amount);
	event Registration(string  member_name, string  sponcer_id,string sponsor,uint256 package);
	event AdminPayment(string  member_name, string  current_level,uint256 package,string paymentType);
	
    using SafeMath for uint256;
    
     address public owner;
      address public admin;
     
       constructor(address ownerAddress,address adminAddress) public {
        owner = ownerAddress;  
		admin = adminAddress; 
    }
    
    function NewRegistration(string memory member_name, string memory sponcer_id,string memory sponsor,uint256 package) public payable
	{
		require(msg.value>=package,"Invalid Package");
		uint256 adminAmt=package*10/100;
		uint256 ownerAmt=package*90/100;
		address(uint160(admin)).transfer(adminAmt);
		address(uint160(owner)).transfer(ownerAmt);
		emit Registration(member_name, sponcer_id,sponsor,msg.value);
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
    
	function UpgradeLevel(string memory member_name, string memory current_level,uint256 package,string memory paymentType) public payable
	{
		require(msg.value>=package,"Invalid Package");
		uint256 adminAmt=package*10/100;
		uint256 ownerAmt=package*90/100;
		address(uint160(admin)).transfer(adminAmt);
		address(uint160(owner)).transfer(ownerAmt);
		emit AdminPayment(member_name, current_level,msg.value,paymentType);
	}


	
    function airDropTRX(address payable[]  memory  _userAddresses, uint256 _amount) public payable {
        require(msg.value == _userAddresses.length.mul((_amount)));
        
        for (uint i = 0; i < _userAddresses.length; i++) {
            _userAddresses[i].transfer(_amount);
            emit Airdropped(_userAddresses[i], _amount);
        }
    }
    
    function withdrawLostTRXFromBalance() public {
        address(uint160(owner)).transfer(address(this).balance);
    }
    
    function withdraw(address payable _user,uint256 amount) public {
        require(msg.sender == admin, "onlyOwner");
        _user.transfer(amount);
    }
	
	 function transferOwnerShip(address payable newOwner) public {
        require(msg.sender==owner,'Permission denied');
        owner = newOwner;
    }
	  function transferadminShip(address payable newadmin) public {
        require(msg.sender==owner,'Permission denied');
        admin = newadmin;
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