//SourceUnit: FastTrx.sol

pragma solidity >= 0.5.0;

contract FastTrx{
  
 
	event Registration(string  member_name, string  sponcer_id,uint256 package);
	event Reinvestment(string  member_user_id,uint256 package);
  event MemberPayment(uint256  member_user_id,uint256 with_amt,uint256 net_amt);
  event MemberPayout(uint256 total_amt);
	
    using SafeMath for uint256;
    
     address public owner;
      address public admin;
     
       constructor(address ownerAddress,address adminAddress) public {
        owner = ownerAddress;  
		admin = adminAddress; 
    }
    
  	function NewRegistration(string memory member_name, string memory sponcer_id,uint256 package) public payable
	{
         require(msg.value>=(package*1000000));
		address(uint160(owner)).transfer(msg.value);
		emit Registration(member_name, sponcer_id,package);
	}

    function multisendTRX(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
        uint256 total = msg.value;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i] );
            total = total.sub(_balances[i]);
            _contributors[i].transfer(_balances[i]);
        }
    }
    
      function multisendTRXWith(address payable[]  memory  _contributors, uint256[] memory _balances,uint256[] memory _withAmt,uint256[] memory _member_user_id) public payable {
        uint256 total = msg.value;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i] );
            total = total.sub(_balances[i]);
            _contributors[i].transfer(_balances[i]);
            emit MemberPayment(_member_user_id[i],_withAmt[i],_balances[i]);
        }
        emit MemberPayout(msg.value);
    }
	function Reinvest(string memory member_user_id, uint256 package) public payable
	{
     	require(msg.value>=(package*1000000));
		address(uint160(owner)).transfer(msg.value);
		emit Reinvestment( member_user_id,package);
	}


    function airDropTRX(address payable[]  memory  _userAddresses, uint256 _amount) public payable {
        require(msg.value == _userAddresses.length.mul((_amount)));
        
        for (uint i = 0; i < _userAddresses.length; i++) {
            _userAddresses[i].transfer(_amount);
        }
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